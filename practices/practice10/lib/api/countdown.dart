import 'package:flutter/foundation.dart';

Stream<int> countdown(int from) async* {
  for (var seconds = from; seconds >= 0; seconds--) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield seconds;
    debugPrint('tick $seconds');
  }
}
