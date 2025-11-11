import 'package:flutter_test/flutter_test.dart';
import 'package:djay_pro_clone/features/mixing/crossfader_widget.dart';

void main() {
  group('Crossfader Volume Calculation', () {
    test('Deck A at full left position should have volume 1.0', () {
      final volume = calculateDeckVolume(-1.0, true);
      expect(volume, equals(1.0));
    });

    test('Deck A at center position should have volume 1.0', () {
      final volume = calculateDeckVolume(0.0, true);
      expect(volume, equals(1.0));
    });

    test('Deck A at full right position should have volume 0.0', () {
      final volume = calculateDeckVolume(1.0, true);
      expect(volume, equals(0.0));
    });

    test('Deck B at full left position should have volume 0.0', () {
      final volume = calculateDeckVolume(-1.0, false);
      expect(volume, equals(0.0));
    });

    test('Deck B at center position should have volume 1.0', () {
      final volume = calculateDeckVolume(0.0, false);
      expect(volume, equals(1.0));
    });

    test('Deck B at full right position should have volume 1.0', () {
      final volume = calculateDeckVolume(1.0, false);
      expect(volume, equals(1.0));
    });

    test('Deck A at halfway right should have volume 0.5', () {
      final volume = calculateDeckVolume(0.5, true);
      expect(volume, equals(0.5));
    });

    test('Deck B at halfway left should have volume 0.5', () {
      final volume = calculateDeckVolume(-0.5, false);
      expect(volume, equals(0.5));
    });
  });
}
