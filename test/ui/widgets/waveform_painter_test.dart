import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:djay_pro_clone/ui/widgets/waveform_painter.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  group('WaveformWidget', () {
    testWidgets('renders a CustomPaint with WaveformPainter', (WidgetTester tester) async {
      final waveformData = [0.5, 0.6, 0.7, 0.6, 0.5];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WaveformWidget(
              waveformData: waveformData,
              playbackPosition: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsOneWidget);
      final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
      expect(customPaint.painter, isA<WaveformPainter>());
    });
  });

  group('WaveformPainter', () {
    late WaveformPainter painter;
    final waveformData = [0.5, 0.6, 0.7, 0.6, 0.5];
    final beatPositions = [0.25, 0.75];

    setUp(() {
      painter = WaveformPainter(
        waveformData: waveformData,
        playbackPosition: 0.5,
        beatPositions: beatPositions,
        playedColor: Colors.blue,
        unplayedColor: Colors.grey,
        beatMarkerColor: Colors.white,
      );
    });

    test('shouldRepaint returns true when playbackPosition changes', () {
      final oldPainter = WaveformPainter(
        waveformData: waveformData,
        playbackPosition: 0.4,
        beatPositions: beatPositions,
      );
      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns true when waveformData changes', () {
      final oldPainter = WaveformPainter(
        waveformData: [0.1, 0.2, 0.3],
        playbackPosition: 0.5,
        beatPositions: beatPositions,
      );
      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns true when beatPositions changes', () {
      final oldPainter = WaveformPainter(
        waveformData: waveformData,
        playbackPosition: 0.5,
        beatPositions: [0.1, 0.9],
      );
      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('shouldRepaint returns false when properties are the same', () {
      final oldPainter = WaveformPainter(
        waveformData: waveformData,
        playbackPosition: 0.5,
        beatPositions: beatPositions,
      );
      expect(painter.shouldRepaint(oldPainter), isFalse);
    });

    test('paint method executes without error', () {
      final mockCanvas = MockCanvas();
      const size = Size(200, 100);
      painter.paint(mockCanvas, size);
      // Verify that some drawing methods were called.
      // This is a basic check to ensure the paint method runs.
      verify(mockCanvas.drawLine(any, any, any)).called(greaterThan(0));
    });

    test('paint does not crash with empty waveform data', () {
      final emptyPainter = WaveformPainter(
        waveformData: [],
        playbackPosition: 0.5,
      );
      final mockCanvas = MockCanvas();
      const size = Size(200, 100);
      emptyPainter.paint(mockCanvas, size);
      verifyNever(mockCanvas.drawLine(any, any, any));
    });
  });
}
