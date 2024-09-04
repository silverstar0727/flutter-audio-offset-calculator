import 'package:flutter_test/flutter_test.dart';

import 'package:audio_offset/audio_offset.dart';

void main() {
  test('adds one to input values', () {
    final calculator = AudioOffset("source.wav", "target.wav");
    expect(calculator.findOffsetBetweenFiles(), isNotNull);
  });
}
