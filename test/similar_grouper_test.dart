import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_finder/data/db/app_database.dart';
import 'package:image_finder/domain/scan/groupers.dart';

Photo _photo({
  required String id,
  String? dHash,
  String? contentHash,
  int size = 1000,
  int createdMs = 1,
  int modifiedMs = 1,
}) {
  return Photo(
    mediaId: id,
    uri: 'content://$id',
    width: 100,
    height: 100,
    sizeBytes: size,
    modifiedMs: modifiedMs,
    createdMs: createdMs,
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
      // Hamming(0, 3) = 2 ≤ 6
      final photos = [
        _photo(id: 'a', dHash: '0'),
        _photo(id: 'b', dHash: '3'),
        _photo(id: 'c', dHash: '4294967295'),
      ];

      final groups = SimilarGrouper().group(photos);
      expect(groups, isNotEmpty);
      final members = groups.expand((g) => g.mediaIds).toSet();
      expect(members.contains('a'), isTrue);
      expect(members.contains('b'), isTrue);
      expect(members.contains('c'), isFalse);
    });

    test('groupFromPayload works for isolate path', () {
      final groups = SimilarGrouper().groupFromPayload(const [
        (mediaId: 'a', dHash: '0', contentHash: null, createdMs: 1),
        (mediaId: 'b', dHash: '3', contentHash: null, createdMs: 1),
      ]);
      expect(groups.single.mediaIds.toSet(), {'a', 'b'});
    });

    test('skips exact content-hash duplicates', () {
      final photos = [
        _photo(id: 'a', dHash: '0', contentHash: 'same'),
        _photo(id: 'b', dHash: '0', contentHash: 'same'),
      ];
      final groups = SimilarGrouper().group(photos);
      expect(groups, isEmpty);
    });

    test('groups near matches within 2 hours', () {
      const t0 = 1_700_000_000_000;
      const thirtyMin = 30 * 60 * 1000;
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: const ['a', 'b'],
        hashes: const [0, 3],
        contentHashes: const [null, null],
        createdMs: const [t0, t0 + thirtyMin],
        threshold: kDefaultSimilarThreshold,
        maxTimeDeltaMs: kDefaultSimilarMaxTimeDeltaMs,
      );
      expect(groups.single.mediaIds.toSet(), {'a', 'b'});
    });

    test('does not group near matches more than 2 hours apart', () {
      const t0 = 1_700_000_000_000;
      const threeHours = 3 * 60 * 60 * 1000;
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: const ['a', 'b'],
        hashes: const [0, 3],
        contentHashes: const [null, null],
        createdMs: const [t0, t0 + threeHours],
        threshold: kDefaultSimilarThreshold,
        maxTimeDeltaMs: kDefaultSimilarMaxTimeDeltaMs,
      );
      expect(groups, isEmpty);
    });

    test('does not transitively merge A-B-C when A far from C', () {
      // A=0, B=7 (bits 0..2 → d=3), C=56 (bits 3..5 → d(B,C)=3), d(A,C)=6
      // Wait d(0,56)=3 actually. Need A far from C.
      // A=0, B=7 (d=3), C = 7<<20 or high bits only: C = 1<<20
      // d(B,C) = hamming(7, 1<<20) = 4, d(A,C) = 1, still close.
      // A=0, B=0x3F (6 bits, d=6), C=0x3F << 10 = bits 10-15
      // d(A,B)=6, d(B,C)=hamming(0x3F, 0x3F<<10)=12 > 6 so no B-C edge.
      // Need d(B,C)<=6 and d(A,C)>6:
      // A=0, B=0x1F (d=5), C=0x1F0 (bits 4-8): 
      // d(A,C)=hamming(0, 0x1F0)=5, still close.
      // A=0, B=0x7 (d=3), C=0x7<<3 = 0x38: d(B,C)=hamming(0x7,0x38)=6, d(A,C)=3.
      //
      // Use: A=0, B=0b000111 (7), C=0b111000 (56)
      // d(A,B)=3, d(B,C)=6, d(A,C)=6 — borderline all within 6.
      //
      // A=0, B=0b001111 (15,d=4), C=0b111100 (60)
      // d(B,C)=hamming(15,60)=4, d(A,C)=4 — all within.
      //
      // Need d(A,C) > 6: A=0, C with 8 bits set far from B's bits
      // B = 0x3F (6 ones), C = 0x3F << 8 = 0x3F00
      // d(A,B)=6, d(B,C)=12 > 6 — no B-C edge with threshold 6.
      //
      // B = 0x1F (5 ones), C = 0x1F << 4 = 0x1F0
      // d(A,B)=5, d(B,C)=hamming(0x1F, 0x1F0)=hamming(31, 496)=
      // 31=0b11111, 496=0b111110000 → xor = 0b1111011111 = bits → count
      // Actually 0x1F xor 0x1F0 = 0x1EF = 8 bits? 
      // 0x1F = 0001 1111, 0x1F0 = 1 1111 0000, xor = 1 1110 1111 = 8 ones. d=8>6.
      //
      // B=0xF (d=4), C=0xF0: xor 0xFF = 8 ones.
      // B=0x7, C=0x38: 0x7 xor 0x38 = 0x3F = 6 ones. d(B,C)=6, d(A,C)=6.
      // Still diameter OK for {A,B,C}.
      //
      // B=0x7, C=0x70: 0x7 xor 0x70 = 0x77 = 7 ones > 6. No B-C edge.
      //
      // B=0xF (4), C=0x78 (0b1111000): xor = 0x77 = 7 ones.
      // B=0xF, C=0x70: xor 0x7F = 7 ones.
      // B=0x7, C=0x3C: 0x7=00111, 0x3C=111100, xor=111011 = 5 ones. d(A,C)=4.
      //
      // Goal d(A,C)>=7: C needs ≥7 bits set and little overlap with B.
      // A=0, B=0b0000111 (7), C=0b1110000 (112): d(A,C)=3, d(B,C)=6.
      // A=0, B=7, C=0b11110000 (240): d(A,C)=4, d(B,C)=hamming(7,240)=7 > 6.
      //
      // So for threshold 6: B=7, C=240 gives no B-C edge.
      // Need d(B,C)<=6 AND d(A,C)>6:
      // C with 7 bits, B with 3 bits overlapping 0: impossible d(A,C)=7 and d(B,C)<=6
      // implies d(A,B) + something... triangle inequality for Hamming:
      // d(A,C) <= d(A,B)+d(B,C) so if d(A,B)=3, d(B,C)=6 then d(A,C)<=9.
      // Can have d(A,C)=7,8,9 with d(A,B)=3, d(B,C)=6.
      //
      // Find C: start from B=7, flip 6 bits that include flipping B's 3 bits off and 3 new on,
      // plus more... 
      // B = 0b0000_0111
      // Flip bits 0,1,2 off and 3,4,5,6,7,8 on = 6 flips → C = 0b1_1111_1000 = 0x1F8
      // d(B,C)=6, d(A,C)=hamming(0, 0x1F8)=6. Still 6.
      // Flip 0,1,2 and 3,4,5,6,7,8,9 — that's 9 flips.
      // Need exactly 6 flips from B to C with popcount(C)>=7.
      // Flip off 0,1,2 (3) and on 4,5,6 (3) → C = 0b0111_0000 = 112, d(A,C)=3.
      // Flip off 1 bit of B and on 5 new: C has 2+5=7 bits, d=6.
      // B=0b111, turn off bit0, turn on 3,4,5,6,7 → C = 0b1111_1010 = 0xFA? 
      // B=0b00000111, clear bit 0 → 0b00000110, set bits 3-7 → 0b11111010 = 250
      // d: changed bit0,3,4,5,6,7 = 6 bits. C popcount = 6 (bits 1,2,3,4,5,6,7 wait)
      // 250 = 11111010 = bits 1,3,4,5,6,7 = 6 ones. d(A,C)=6.
      //
      // Clear 0,1 set 3,4,5,6,7,8: from B 0b111 → 0b1_1111_1100 = 0x1FC
      // changes: 0,1,3,4,5,6,7,8 = 8 flips.
      //
      // d(A,B)=5, d(B,C)=6 → d(A,C) can be 7..11
      // B = 0x1F (5 bits), transform with 6 flips to get 7+ bits in C.
      // Clear all 5 of B, set 6 new bits far: 11 flips.
      // Clear 2 of B, set 4 new: 6 flips, C has 3+4=7 bits. d(A,C)=7. Perfect!
      // B = 0b0001_1111 (31)
      // Clear bits 0,1 → temp 0b0001_1100
      // Set bits 6,7,8,9 → C = 0b0011_1101_1100 = 0x3DC?
      // bits: 2,3,4,6,7,8,9 = 7 ones. 
      // From B=0b0011111: flip 0,1 (off), flip 6,7,8,9 (on) = 6 flips.
      // C = (31 ^ 0b11) | 0b1111000000 = 0b11100 | 0x3C0 = 0x3DC
      // 31^3=28=0b11100, then OR 0x3C0 = 0b11_1101_1100 = 988 = 0x3DC
      // d(A,C)=popcount(0x3DC)=popcount(988)=8? 0x3DC=0011 1101 1100 = 8 ones.
      // bits 2,3,4,6,7,8,9 — that's 7. 0x3DC = 1111011100 = bits 2,3,4,6,7,8,9 = 7.
      // 0x3DC = 988 = 512+256+128+64+16+8+4 = 7 bits. Good d(A,C)=7 > 6.
      // d(B,C)=6, d(A,B)=5. Good.

      const a = 0;
      const b = 0x1F; // 31
      const c = 0x3DC; // 988

      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: const ['a', 'b', 'c'],
        hashes: const [a, b, c],
        contentHashes: const [null, null, null],
        createdMs: const [1, 1, 1],
        threshold: kDefaultSimilarThreshold,
      );

      // Must not be a single triple {a,b,c}.
      expect(groups.any((g) => g.mediaIds.length >= 3), isFalse);
      final allMembers = groups.expand((g) => g.mediaIds).toSet();
      // At least one genuine pair should survive.
      expect(allMembers.length, greaterThanOrEqualTo(2));
    });

    test('keeps tight burst as one group', () {
      // All hashes within Hamming 2 of each other (0,1,2,3).
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: const ['a', 'b', 'c', 'd'],
        hashes: const [0, 1, 2, 3],
        contentHashes: const [null, null, null, null],
        createdMs: const [1, 1, 1, 1],
        threshold: kDefaultSimilarThreshold,
      );
      expect(groups.length, 1);
      expect(groups.single.mediaIds.toSet(), {'a', 'b', 'c', 'd'});
    });

    test('caps group size at maxGroupSize', () {
      // 50 identical hashes → at most 40 in one group.
      final mediaIds = List.generate(50, (i) => '$i');
      final hashes = List.filled(50, 0);
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: mediaIds,
        hashes: hashes,
        contentHashes: List.filled(50, null),
        createdMs: List.filled(50, 1),
        threshold: kDefaultSimilarThreshold,
        maxGroupSize: kDefaultSimilarMaxGroupSize,
      );
      expect(groups, isNotEmpty);
      expect(
        groups.every((g) => g.mediaIds.length <= kDefaultSimilarMaxGroupSize),
        isTrue,
      );
    });

    test('groups 3600 fingerprints quickly', () {
      final rnd = Random(42);
      final mediaIds = List.generate(3600, (i) => '$i');
      final hashes = List.generate(
        3600,
        (_) => rnd.nextInt(1 << 30) ^ (rnd.nextInt(1 << 30) << 20),
      );
      final content = List<String?>.filled(3600, null);
      final times = List<int>.filled(3600, 1);

      final sw = Stopwatch()..start();
      final groups = SimilarGrouper.groupFromParsed(
        mediaIds: mediaIds,
        hashes: hashes,
        contentHashes: content,
        createdMs: times,
        threshold: kDefaultSimilarThreshold,
      );
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(5000));
      expect(groups, isA<List>());
    });
  });
}
