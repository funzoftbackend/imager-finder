import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_finder/data/db/app_database.dart';
import 'package:image_finder/domain/scan/groupers.dart';

Photo _photo({
  required String id,
  String? dHash,
  String? contentHash,
  int size = 1000,
}) {
  return Photo(
    mediaId: id,
    uri: 'content://$id',
    width: 100,
    height: 100,
    sizeBytes: size,
    modifiedMs: 1,
    createdMs: 1,
    contentHash: contentHash,
    dHash: dHash,
    pHash: null,
    indexedAtMs: 1,
    path: null,
    mime: null,
    album: null,
  );
}

void main() {
  group('SimilarGrouper', () {
    test('groups near dHash matches under threshold', () {
      final photos = [
        _photo(id: 'a', dHash: '0'),
        _photo(id: 'b', dHash: '3'),
        _photo(id: 'c', dHash: '4294967295'),
      ];

      final groups = SimilarGrouper(threshold: 12).group(photos);
      expect(groups, isNotEmpty);
      final members = groups.expand((g) => g.mediaIds).toSet();
      expect(members.contains('a'), isTrue);
      expect(members.contains('b'), isTrue);
      expect(members.contains('c'), isFalse);
    });

    test('groupFromPayload works for isolate path', () {
      final groups = SimilarGrouper(threshold: 12).groupFromPayload(const [
        (mediaId: 'a', dHash: '0', contentHash: null),
        (mediaId: 'b', dHash: '3', contentHash: null),
      ]);
      expect(groups.single.mediaIds.toSet(), {'a', 'b'});
    });

    test('skips exact content-hash duplicates', () {
      final photos = [
        _photo(id: 'a', dHash: '0', contentHash: 'same'),
        _photo(id: 'b', dHash: '0', contentHash: 'same'),
      ];
      final groups = SimilarGrouper(threshold: 12).group(photos);
      expect(groups, isEmpty);
    });

    test('groups 3600 fingerprints quickly', () {
      final rnd = Random(42);
      final mediaIds = List.generate(3600, (i) => '$i');
      final hashes = List.generate(
        3600,
        (_) => rnd.nextInt(1 << 30) ^ (rnd.nextInt(1 << 30) << 20),
      );
      final content = List<String?>.filled(3600, null);

      final sw = Stopwatch()..start();
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: mediaIds,
        hashes: hashes,
        contentHashes: content,
        threshold: 12,
      );
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(5000));
      expect(groups, isA<List>());
    });
  });
}
