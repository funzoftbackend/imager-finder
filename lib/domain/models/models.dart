enum ScanPhase {
  idle,
  permission,
  catalog,
  diff,
  exact,
  similar,
  grouping,
  persist,
  done,
  error,
}

extension ScanPhaseLabel on ScanPhase {
  /// User-facing status label (never show raw enum names in UI).
  String get label => switch (this) {
        ScanPhase.idle => 'Ready',
        ScanPhase.permission => 'Permission',
        ScanPhase.catalog => 'Reading gallery',
        ScanPhase.diff => 'Comparing changes',
        ScanPhase.exact => 'Exact duplicates',
        ScanPhase.similar => 'Similar photos',
        ScanPhase.grouping => 'Matching similar',
        ScanPhase.persist => 'Saving',
        ScanPhase.done => 'Done',
        ScanPhase.error => 'Error',
      };

  /// Phases where the bar should be indeterminate (no meaningful %).
  bool get indeterminateProgress =>
      this == ScanPhase.permission ||
      this == ScanPhase.grouping ||
      this == ScanPhase.persist;
}

class ScanProgress {
  const ScanProgress({
    required this.phase,
    this.processed = 0,
    this.total = 0,
    this.message = '',
    this.photosPerSecond = 0,
    this.exactGroups = 0,
    this.similarGroups = 0,
    this.darkCount = 0,
    this.blurryCount = 0,
    this.error,
  });

  final ScanPhase phase;
  final int processed;
  final int total;
  final String message;
  final double photosPerSecond;
  final int exactGroups;
  final int similarGroups;
  final int darkCount;
  final int blurryCount;
  final String? error;

  double get fraction {
    if (total <= 0) return 0;
    return (processed / total).clamp(0.0, 1.0);
  }

  ScanProgress copyWith({
    ScanPhase? phase,
    int? processed,
    int? total,
    String? message,
    double? photosPerSecond,
    int? exactGroups,
    int? similarGroups,
    int? darkCount,
    int? blurryCount,
    String? error,
  }) {
    return ScanProgress(
      phase: phase ?? this.phase,
      processed: processed ?? this.processed,
      total: total ?? this.total,
      message: message ?? this.message,
      photosPerSecond: photosPerSecond ?? this.photosPerSecond,
      exactGroups: exactGroups ?? this.exactGroups,
      similarGroups: similarGroups ?? this.similarGroups,
      darkCount: darkCount ?? this.darkCount,
      blurryCount: blurryCount ?? this.blurryCount,
      error: error,
    );
  }
}

class CatalogAsset {
  const CatalogAsset({
    required this.mediaId,
    required this.uri,
    required this.sizeBytes,
    required this.modifiedMs,
    this.path,
    this.width = 0,
    this.height = 0,
    this.createdMs = 0,
    this.mime,
    this.album,
  });

  final String mediaId;
  final String uri;
  final String? path;
  final int width;
  final int height;
  final int sizeBytes;
  final int modifiedMs;
  final int createdMs;
  final String? mime;
  final String? album;
}

class DiffResult {
  const DiffResult({
    required this.added,
    required this.modified,
    required this.deletedIds,
    required this.unchangedIds,
  });

  final List<CatalogAsset> added;
  final List<CatalogAsset> modified;
  final List<String> deletedIds;
  final List<String> unchangedIds;

  List<CatalogAsset> get needsWork => [...added, ...modified];
}

class DupeGroup {
  const DupeGroup({
    required this.id,
    required this.mediaIds,
    this.contentHash,
    this.maxDistance = 0,
    this.totalBytes = 0,
  });

  final int id;
  final List<String> mediaIds;
  final String? contentHash;
  final int maxDistance;
  final int totalBytes;
}
