import 'package:flutter_test/flutter_test.dart';
import 'package:image_finder/domain/scan/bk_tree.dart';
import 'package:image_finder/domain/models/models.dart';
import 'package:image_finder/domain/scan/diff_engine.dart';

void main() {
  group('BkTree', () {
    test('finds near hashes within Hamming distance', () {
      final tree = BkTree();
      tree.insert('a', 0);
      tree.insert('b', 1); // distance 1
      tree.insert('c', 255); // distant

      final hits = tree.search(0, maxDistance: 2);
      final ids = hits.map((h) => h.mediaId).toSet();
      expect(ids.contains('a'), isTrue);
      expect(ids.contains('b'), isTrue);
      expect(ids.contains('c'), isFalse);
    });

    test('hamming counts differing bits', () {
      expect(BkTree.hamming(0, 0), 0);
      expect(BkTree.hamming(1, 0), 1);
      expect(BkTree.hamming(7, 0), 3);
      expect(BkTree.hamming(3, 0), 2);
    });

    test('parseHash accepts unsigned 64-bit decimals from native', () {
      // Value that fails int.parse on 64-bit signed limit.
      const raw = '17430056384809778366';
      final hash = BkTree.parseHash(raw);
      expect(hash, isNot(0));
      expect(BkTree.hamming(hash, hash), 0);
      // Round-trip bit pattern via unsigned string form.
      final again = BkTree.parseHash(
        (BigInt.from(hash).toUnsigned(64)).toString(),
      );
      expect(again, hash);
    });
  });

  group('DiffEngine', () {
    test('classifies added modified deleted unchanged', () {
      final engine = DiffEngine();
      final catalog = [
        const CatalogAsset(
          mediaId: '1',
          uri: 'content://1',
          sizeBytes: 100,
          modifiedMs: 1,
        ),
        const CatalogAsset(
          mediaId: '2',
          uri: 'content://2',
          sizeBytes: 200,
          modifiedMs: 2,
        ),
      ];
      final result = engine.diff(catalog: catalog, existing: {});
      expect(result.added.length, 2);
      expect(result.deletedIds, isEmpty);
      expect(result.unchangedIds, isEmpty);
    });
  });
}
