import 'package:flutter/services.dart';

import '../../domain/models/models.dart';
import '../../domain/scan/quality_metrics.dart';

/// Client for the Android [HashEngine] / [ScanEngine] MethodChannel.
class NativeHashClient {
  NativeHashClient({
    MethodChannel? channel,
  }) : _channel =
            channel ??
            const MethodChannel('com.imagefinder.image_finder/hash_engine');

  final MethodChannel _channel;

  /// Bulk MediaStore inventory (native single cursor). Empty on failure/unsupported.
  Future<List<CatalogAsset>> catalogImages() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('catalogImages');
    if (raw == null) return const [];
    return [
      for (final row in raw)
        if (row is Map)
          CatalogAsset(
            mediaId: '${row['mediaId']}',
            uri: '${row['uri']}',
            path: row['path'] as String?,
            width: (row['width'] as num?)?.toInt() ?? 0,
            height: (row['height'] as num?)?.toInt() ?? 0,
            sizeBytes: (row['sizeBytes'] as num?)?.toInt() ?? 0,
            modifiedMs: (row['modifiedMs'] as num?)?.toInt() ?? 0,
            createdMs: (row['createdMs'] as num?)?.toInt() ?? 0,
            mime: row['mime'] as String?,
            album: row['album'] as String?,
          ),
    ];
  }

  /// Parallel native fingerprints: dHash + dark/blur scores.
  /// Returns map uri → [PhotoFingerprint] (missing entries failed).
  Future<Map<String, PhotoFingerprint>> computeDHashBatch(
    List<String> uris,
  ) async {
    if (uris.isEmpty) return const {};
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'computeDHashBatch',
      {'uris': uris},
    );
    if (raw == null) return const {};
    final out = <String, PhotoFingerprint>{};
    for (final row in raw) {
      final fp = _parseFingerprint(row);
      if (fp != null) out[fp.$1] = fp.$2;
    }
    return out;
  }

  /// Single-URI fallback fingerprint (dHash + quality).
  Future<PhotoFingerprint> analyzeImage(String uri) async {
    final raw = await _channel.invokeMethod<dynamic>(
      'analyzeImage',
      {'uri': uri},
    );
    final parsed = _parseFingerprint(raw);
    if (parsed == null) {
      throw StateError('analyzeImage returned incomplete data for $uri');
    }
    return parsed.$2;
  }

  (String, PhotoFingerprint)? _parseFingerprint(dynamic row) {
    if (row is! Map) return null;
    final uri = row['uri'] as String?;
    final dHash = row['dHash'] as String?;
    final mean = (row['meanLuminance'] as num?)?.toDouble();
    final blur = (row['blurScore'] as num?)?.toDouble();
    if (uri == null ||
        dHash == null ||
        dHash.isEmpty ||
        mean == null ||
        blur == null) {
      return null;
    }
    return (
      uri,
      PhotoFingerprint(
        dHash: dHash,
        meanLuminance: mean,
        blurScore: blur,
      ),
    );
  }

  Future<String> computeContentHash(String uri) async {
    final result = await _channel.invokeMethod<String>(
      'computeContentHash',
      {'uri': uri},
    );
    if (result == null) {
      throw StateError('computeContentHash returned null for $uri');
    }
    return result;
  }

  Future<String> computeDHash(String uri, {int targetSize = 9}) async {
    final result = await _channel.invokeMethod<String>(
      'computeDHash',
      {'uri': uri, 'targetSize': targetSize},
    );
    if (result == null) {
      throw StateError('computeDHash returned null for $uri');
    }
    return result;
  }

  Future<String> computeDHashFromBytes(Uint8List bytes) async {
    final result = await _channel.invokeMethod<String>(
      'computeDHashFromBytes',
      {'bytes': bytes},
    );
    if (result == null) {
      throw StateError('computeDHashFromBytes returned null');
    }
    return result;
  }

  Future<String> computePHash(String uri, {int targetSize = 32}) async {
    final result = await _channel.invokeMethod<String>(
      'computePHash',
      {'uri': uri, 'targetSize': targetSize},
    );
    if (result == null) {
      throw StateError('computePHash returned null for $uri');
    }
    return result;
  }

  Future<String> computePHashFromBytes(Uint8List bytes) async {
    final result = await _channel.invokeMethod<String>(
      'computePHashFromBytes',
      {'bytes': bytes},
    );
    if (result == null) {
      throw StateError('computePHashFromBytes returned null');
    }
    return result;
  }
}
