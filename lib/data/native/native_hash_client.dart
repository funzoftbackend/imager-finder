import 'dart:async';

import 'package:flutter/services.dart';

/// Client for the Android [HashEngine] MethodChannel.
class NativeHashClient {
  NativeHashClient({
    MethodChannel? channel,
  }) : _channel =
            channel ??
            const MethodChannel('com.imagefinder.image_finder/hash_engine');

  final MethodChannel _channel;

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
