import 'package:collection/collection.dart';

import '../../data/db/app_database.dart';
import 'bk_tree.dart';

/// Lightweight transferable record for isolate-based similar grouping.
typedef SimilarHashPayload = ({
  String mediaId,
  String dHash,
  String? contentHash,
});

/// Compact isolate args — ints parse once on the caller side.
typedef SimilarGroupIsolateArgs = ({
  List<String> mediaIds,
  List<int> hashes,
  List<String?> contentHashes,
  int threshold,
});

class ExactGrouper {
  /// Groups photos that share a content hash (size-bucket candidates only hashed).
  List<({String contentHash, List<String> mediaIds, int totalBytes})> group(
    List<Photo> photos,
  ) {
    final byHash = <String, List<Photo>>{};
    for (final photo in photos) {
      final hash = photo.contentHash;
      if (hash == null || hash.isEmpty) continue;
      byHash.putIfAbsent(hash, () => []).add(photo);
    }

    return byHash.entries
        .where((e) => e.value.length >= 2)
        .map((e) {
          final ids = e.value.map((p) => p.mediaId).toList();
          final total = e.value.fold<int>(0, (sum, p) => sum + p.sizeBytes);
          return (
            contentHash: e.key,
            mediaIds: ids,
            totalBytes: total,
          );
        })
        .sortedBy<num>((g) => -g.totalBytes)
        .toList();
  }

  /// Returns mediaIds that share a file size with at least one other photo.
  Set<String> sizeCollisionCandidates(List<Photo> photos) {
    final bySize = <int, List<String>>{};
    for (final photo in photos) {
      bySize.putIfAbsent(photo.sizeBytes, () => []).add(photo.mediaId);
    }
    final candidates = <String>{};
    for (final entry in bySize.entries) {
      if (entry.value.length >= 2) {
        candidates.addAll(entry.value);
      }
    }
    return candidates;
  }
}

class SimilarGrouper {
  SimilarGrouper({this.threshold = 12, this.confirmThreshold = 14});

  /// Hamming distance for dHash matches (0 identical … 64 opposite).
  final int threshold;

  /// Reserved for optional pHash confirmation (currently unused on scan path).
  final int confirmThreshold;

  List<({List<String> mediaIds, int maxDistance})> group(
    List<Photo> photos, {
    Map<String, String>? pHashes,
  }) {
    return groupFromPayload([
      for (final p in photos)
        if (p.dHash != null && p.dHash!.isNotEmpty)
          (
            mediaId: p.mediaId,
            dHash: p.dHash!,
            contentHash: p.contentHash,
          ),
    ]);
  }

  /// Isolate-friendly grouping from plain hash payloads.
  List<({List<String> mediaIds, int maxDistance})> groupFromPayload(
    List<SimilarHashPayload> entries, {
    Map<String, String>? pHashes,
  }) {
    if (entries.isEmpty) return const [];

    final mediaIds = <String>[];
    final hashes = <int>[];
    final contentHashes = <String?>[];
    for (final e in entries) {
      mediaIds.add(e.mediaId);
      hashes.add(BkTree.parseHash(e.dHash));
      contentHashes.add(e.contentHash);
    }

    return groupFromParsed(
      mediaIds: mediaIds,
      hashes: hashes,
      contentHashes: contentHashes,
      threshold: threshold,
    );
  }

  /// Fast similar grouping:
  /// 1) exact dHash map
  /// 2) 8×8-bit LSH bands for near matches (avoids BK-tree O(n²) blow-up)
  /// 3) Hamming verify + union-find
  ///
  /// BK-tree with radius 12 barely prunes on 64-bit hashes, so ~3k photos
  /// felt "stuck" for minutes on the grouping step.
  static List<({List<String> mediaIds, int maxDistance})> groupFromParsed({
    required List<String> mediaIds,
    required List<int> hashes,
    required List<String?> contentHashes,
    required int threshold,
  }) {
    final n = mediaIds.length;
    if (n == 0) return const [];

    final parent = List<int>.generate(n, (i) => i);
    final rank = List<int>.filled(n, 0);
    final maxDist = List<int>.filled(n, 0);

    int find(int x) {
      var root = x;
      while (parent[root] != root) {
        root = parent[root];
      }
      var cur = x;
      while (cur != root) {
        final next = parent[cur];
        parent[cur] = root;
        cur = next;
      }
      return root;
    }

    void union(int a, int b, int distance) {
      var ra = find(a);
      var rb = find(b);
      if (ra == rb) {
        if (distance > maxDist[ra]) maxDist[ra] = distance;
        return;
      }
      if (rank[ra] < rank[rb]) {
        final tmp = ra;
        ra = rb;
        rb = tmp;
      }
      parent[rb] = ra;
      if (rank[ra] == rank[rb]) rank[ra]++;
      final merged =
          maxDist[ra] > maxDist[rb] ? maxDist[ra] : maxDist[rb];
      maxDist[ra] = merged > distance ? merged : distance;
    }

    bool skipExactPair(int i, int j) {
      final a = contentHashes[i];
      final b = contentHashes[j];
      return a != null && a.isNotEmpty && a == b;
    }

    // —— Exact dHash groups (O(n)) ——
    final firstOfHash = <int, int>{};
    for (var i = 0; i < n; i++) {
      final prev = firstOfHash[hashes[i]];
      if (prev == null) {
        firstOfHash[hashes[i]] = i;
        continue;
      }
      if (!skipExactPair(i, prev)) {
        union(i, prev, 0);
      }
    }

    // —— Near matches via 8-bit bands (8 bands cover 64-bit hash) ——
    // Photos that share any identical band become candidates; Hamming verifies.
    const bandBits = 8;
    const bandMask = (1 << bandBits) - 1;
    const bandCount = 64 ~/ bandBits; // 8
    // Cap pairwise work inside huge collision buckets (e.g. blank thumbs).
    const maxBucketPairs = 120;

    for (var band = 0; band < bandCount; band++) {
      final shift = band * bandBits;
      final buckets = <int, List<int>>{};
      for (var i = 0; i < n; i++) {
        final key = (hashes[i] >> shift) & bandMask;
        (buckets[key] ??= <int>[]).add(i);
      }

      for (final bucket in buckets.values) {
        final size = bucket.length;
        if (size < 2) continue;
        final limit = size > maxBucketPairs ? maxBucketPairs : size;
        for (var x = 0; x < limit; x++) {
          final i = bucket[x];
          for (var y = x + 1; y < limit; y++) {
            final j = bucket[y];
            if (skipExactPair(i, j)) continue;
            final d = BkTree.hamming(hashes[i], hashes[j]);
            if (d <= threshold) {
              union(i, j, d);
            }
          }
        }
      }
    }

    final buckets = <int, List<String>>{};
    final distByRoot = <int, int>{};
    for (var i = 0; i < n; i++) {
      final root = find(i);
      (buckets[root] ??= <String>[]).add(mediaIds[i]);
      distByRoot[root] = maxDist[root];
    }

    return buckets.entries
        .where((e) => e.value.length >= 2)
        .map(
          (e) => (
            mediaIds: e.value,
            maxDistance: distByRoot[e.key] ?? 0,
          ),
        )
        .sortedBy<num>((g) => -g.mediaIds.length)
        .toList();
  }
}

/// Top-level entry for [Isolate.run] — must stay top-level/static.
List<({List<String> mediaIds, int maxDistance})> groupSimilarInIsolate(
  SimilarGroupIsolateArgs args,
) {
  return SimilarGrouper.groupFromParsed(
    mediaIds: args.mediaIds,
    hashes: args.hashes,
    contentHashes: args.contentHashes,
    threshold: args.threshold,
  );
}
