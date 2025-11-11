import 'package:flutter/material.dart';

/// Custom painter for rendering audio waveforms
class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double playbackPosition; // 0.0 to 1.0
  final List<double> beatPositions; // Positions of beat markers (0.0 to 1.0)
  final Color playedColor;
  final Color unplayedColor;
  final Color beatMarkerColor;

  WaveformPainter({
    required this.waveformData,
    required this.playbackPosition,
    this.beatPositions = const [],
    this.playedColor = Colors.blue,
    this.unplayedColor = Colors.grey,
    this.beatMarkerColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    // Draw waveform bars
    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      final amplitude = waveformData[i];
      final barHeight = amplitude * size.height * 0.5;

      // Determine color based on playback position
      final normalizedPosition = i / waveformData.length;
      paint.color = normalizedPosition <= playbackPosition
          ? playedColor
          : unplayedColor;

      // Draw symmetric waveform (top and bottom)
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }

    // Draw beat markers
    final beatPaint = Paint()
      ..color = beatMarkerColor.withOpacity(0.5)
      ..strokeWidth = 1;

    for (final beatPos in beatPositions) {
      final x = beatPos * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        beatPaint,
      );
    }

    // Draw playback position indicator
    final playbackX = playbackPosition * size.width;
    final playbackPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(playbackX, 0),
      Offset(playbackX, size.height),
      playbackPaint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    // Only repaint when playback position or data changes
    return oldDelegate.playbackPosition != playbackPosition ||
        oldDelegate.waveformData != waveformData ||
        oldDelegate.beatPositions != beatPositions;
  }
}

/// Widget that displays an audio waveform with playback position
class WaveformWidget extends StatelessWidget {
  final List<double> waveformData;
  final double playbackPosition;
  final List<double> beatPositions;
  final double height;

  const WaveformWidget({
    super.key,
    required this.waveformData,
    this.playbackPosition = 0.0,
    this.beatPositions = const [],
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: WaveformPainter(
            waveformData: waveformData,
            playbackPosition: playbackPosition,
            beatPositions: beatPositions,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
