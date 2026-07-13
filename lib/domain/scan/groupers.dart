import 'package:collection/collection.dart';

import '../../data/db/app_database.dart';
import 'bk_tree.dart';

/// Default: only link similar photos taken within 2 hours.
const int kDefaultSimilarMaxTimeDeltaMs = 2 * 60 * 60 * 1000;

/// Stricter Hamming cutoff (was 12 — too loose with transitive merge).
const int kDefaultSimilarThreshold = 6;

/// Safety cap for a single similar group (pathological thumb hubs).
const int kDefaultSimilarMaxGroupSize = 40;

/// Lightweight transferable record for isolate-based similar grouping.
typedef SimilarHashPayload = ({
  String mediaId,
  String dHash,
  String? contentHash,
  int createdMs,
});

/// Compact isolate args — ints parse once on the caller side.
typedef SimilarGroupIsolateArgs = ({
  List<String> mediaIds,
  List<int> hashes,
  List<String?> contentHashes,
  List<int> createdMs,
  int threshold,
  int maxTimeDeltaMs,
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
  SimilarGrouper({
    this.threshold = kDefaultSimilarThreshold,
    this.confirmThreshold = 14,
    this.maxTimeDeltaMs = kDefaultSimilarMaxTimeDeltaMs,
    this.maxGroupSize = kDefaultSimilarMaxGroupSize,
  });

  /// Hamming distance for dHash matches (0 identical … 64 opposite).
  final int threshold;

  /// Reserved for optional pHash confirmation (currently unused on scan path).
  final int confirmThreshold;

  /// Max |captureTimeA - captureTimeB| to allow a similar link.
  final int maxTimeDeltaMs;

  /// Max photos in one similar group.
  final int maxGroupSize;

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
            createdMs: p.createdMs > 0 ? p.createdMs : p.modifiedMs,
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
    final createdMs = <int>[];
    for (final e in entries) {
      mediaIds.add(e.mediaId);
      hashes.add(BkTree.parseHash(e.dHash));
      contentHashes.add(e.contentHash);
      createdMs.add(e.createdMs);
    }

    return groupFromParsed(
      mediaIds: mediaIds,
      hashes: hashes,
      contentHashes: contentHashes,
      createdMs: createdMs,
      threshold: threshold,
      maxTimeDeltaMs: maxTimeDeltaMs,
      maxGroupSize: maxGroupSize,
    );
  }

  /// Fast similar grouping (no transitive mega-groups):
  /// 1) LSH candidate edges with Hamming ≤ threshold and 2h window
  /// 2) Center-star clusters with diameter ≤ threshold (no long chains)
  /// 3) Cap group size
  static List<({List<String> mediaIds, int maxDistance})> groupFromParsed({
    required List<String> mediaIds,
    required List<int> hashes,
    required List<String?> contentHashes,
    required List<int> createdMs,
    required int threshold,
    int maxTimeDeltaMs = kDefaultSimilarMaxTimeDeltaMs,
    int maxGroupSize = kDefaultSimilarMaxGroupSize,
  }) {
    final n = mediaIds.length;
    if (n == 0) return const [];

    bool skipExactPair(int i, int j) {
      final a = contentHashes[i];
      final b = contentHashes[j];
      return a != null && a.isNotEmpty && a == b;
    }

    bool withinTimeWindow(int i, int j) {
      final a = createdMs[i];
      final b = createdMs[j];
      if (a <= 0 || b <= 0) return true;
      return (a - b).abs() <= maxTimeDeltaMs;
    }

    // Adjacency: neighbor index + Hamming distance.
    final neighbors = List.generate(n, (_) => <({int j, int d})>[]);

    void addEdge(int i, int j, int d) {
      if (i == j) return;
      neighbors[i].add((j: j, d: d));
      neighbors[j].add((j: i, d: d));
    }

    // —— Exact dHash edges (within time window) ——
    final byExactHash = <int, List<int>>{};
    for (var i = 0; i < n; i++) {
      (byExactHash[hashes[i]] ??= <int>[]).add(i);
    }
    for (final bucket in byExactHash.values) {
      if (bucket.length < 2) continue;
      final limit =
          bucket.length > maxGroupSize ? maxGroupSize : bucket.length;
      for (var x = 0; x < limit; x++) {
        for (var y = x + 1; y < limit; y++) {
          final i = bucket[x];
          final j = bucket[y];
          if (skipExactPair(i, j)) continue;
          if (!withinTimeWindow(i, j)) continue;
          addEdge(i, j, 0);
        }
      }
    }

    // —— Near matches via 8-bit LSH bands ——
    const bandBits = 8;
    const bandMask = (1 << bandBits) - 1;
    const bandCount = 64 ~/ bandBits;
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
            if (!withinTimeWindow(i, j)) continue;
            final d = BkTree.hamming(hashes[i], hashes[j]);
            if (d <= threshold) {
              addEdge(i, j, d);
            }
          }
        }
      }
    }

    // Dedupe neighbor lists (same pair may appear from multiple bands).
    for (var i = 0; i < n; i++) {
      final best = <int, int>{};
      for (final e in neighbors[i]) {
        final prev = best[e.j];
        if (prev == null || e.d < prev) best[e.j] = e.d;
      }
      neighbors[i] = [
        for (final e in best.entries) (j: e.key, d: e.value),
      ]..sort((a, b) => a.d.compareTo(b.d));
    }

    // —— Center-star clusters with diameter ≤ threshold ——
    final assigned = List<bool>.filled(n, false);
    final groups = <({List<String> mediaIds, int maxDistance})>[];

    while (true) {
      var center = -1;
      var bestDegree = -1;
      for (var i = 0; i < n; i++) {
        if (assigned[i]) continue;
        var degree = 0;
        for (final e in neighbors[i]) {
          if (!assigned[e.j]) degree++;
        }
        if (degree > bestDegree) {
          bestDegree = degree;
          center = i;
        }
      }
      if (center < 0) break;

      if (bestDegree <= 0) {
        assigned[center] = true;
        continue;
      }

      final memberIdx = <int>[center];
      assigned[center] = true;
      var maxDistance = 0;

      for (final e in neighbors[center]) {
        if (assigned[e.j]) continue;
        if (memberIdx.length >= maxGroupSize) break;
        if (e.d > threshold) continue;

        // Diameter: must stay within threshold of every current member.
        var ok = true;
        for (final m in memberIdx) {
          final dm = m == center
              ? e.d
              : BkTree.hamming(hashes[e.j], hashes[m]);
          if (dm > threshold) {
            ok = false;
            break;
          }
          if (dm > maxDistance) maxDistance = dm;
        }
        if (!ok) continue;

        memberIdx.add(e.j);
        assigned[e.j] = true;
        if (e.d > maxDistance) maxDistance = e.d;
      }

      if (memberIdx.length >= 2) {
        groups.add((
          mediaIds: [for (final i in memberIdx) mediaIds[i]],
          maxDistance: maxDistance,
        ));
      }
    }

    return groups.sortedBy<num>((g) => -g.mediaIds.length).toList();
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
    createdMs: args.createdMs,
    threshold: args.threshold,
    maxTimeDeltaMs: args.maxTimeDeltaMs,
  );
}
