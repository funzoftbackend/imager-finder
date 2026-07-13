/// BK-tree for 64-bit hashes under Hamming distance.
class BkTree {
  _BkNode? _root;

  void insert(String mediaId, int hash) {
    final node = _BkNode(mediaId: mediaId, hash: hash);
    final root = _root;
    if (root == null) {
      _root = node;
      return;
    }
    var current = root;
    while (true) {
      final d = hamming(current.hash, hash);
      final child = current.children[d];
      if (child == null) {
        current.children[d] = node;
        return;
      }
      current = child;
    }
  }

  List<({String mediaId, int distance})> search(
    int hash, {
    required int maxDistance,
  }) {
    final root = _root;
    if (root == null) return const [];
    final results = <({String mediaId, int distance})>[];
    final queue = <_BkNode>[root];
    while (queue.isNotEmpty) {
      final node = queue.removeLast();
      final d = hamming(node.hash, hash);
      if (d <= maxDistance) {
        results.add((mediaId: node.mediaId, distance: d));
      }
      final low = d - maxDistance;
      final high = d + maxDistance;
      for (final entry in node.children.entries) {
        if (entry.key >= low && entry.key <= high) {
          queue.add(entry.value);
        }
      }
    }
    return results;
  }

  /// Kernighan bit-count — much faster than walking every bit.
  static int hamming(int a, int b) {
    var x = a ^ b;
    var count = 0;
    while (x != 0) {
      x &= x - 1;
      count++;
    }
    return count;
  }

  /// Parses unsigned 64-bit hash decimals from native/Dart (may exceed signed max).
  ///
  /// Example that breaks [int.parse]: `17430056384809778366`.
  static int parseHash(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw FormatException('Empty hash', value);
    }
    // Hex form (optional future / already-hex strings).
    if (trimmed.length == 16 &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(trimmed)) {
      return BigInt.parse(trimmed, radix: 16).toSigned(64).toInt();
    }
    final big = BigInt.parse(trimmed);
    // Reinterpret low 64 bits as signed so XOR/Hamming stay correct.
    return big.toUnsigned(64).toSigned(64).toInt();
  }
}

class _BkNode {
  _BkNode({required this.mediaId, required this.hash});

  final String mediaId;
  final int hash;
  final Map<int, _BkNode> children = {};
}
