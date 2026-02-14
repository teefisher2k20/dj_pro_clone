import 'package:flutter/material.dart';

class WaveformWidget extends StatefulWidget {
  final List<double> waveformData;
  final Duration currentPosition;
  final Duration totalDuration;
  final Color waveColor;
  final Color playedColor;
  final Color playheadColor;
  final Function(Duration)? onSeek;
  final double height;
  final Duration? ghostPosition; // For Slip Mode
  final List<Duration>? slicerSegments; // For Slicer Mode

  const WaveformWidget({
    super.key,
    required this.waveformData,
    required this.currentPosition,
    required this.totalDuration,
    this.waveColor = Colors.grey,
    this.playedColor = const Color(0xFF00D9FF),
    this.playheadColor = Colors.white,
    this.onSeek,
    this.height = 100,
    this.ghostPosition,
    this.slicerSegments,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: WaveformPainter(
            waveformData: widget.waveformData,
            currentPosition: widget.currentPosition,
            totalDuration: widget.totalDuration,
            waveColor: widget.waveColor,
            playedColor: widget.playedColor,
            playheadColor: widget.playheadColor,
            ghostPosition: widget.ghostPosition,
            slicerSegments: widget.slicerSegments,
          ),
          child: Container(),
        ),
      ),
    );
  }

  void _handleTap(TapDownDetails details) {
    if (widget.onSeek == null) return;

    // Calculate seek position
    final width = context.size?.width ?? 0;
    final tapX = details.localPosition.dx;
    final percentage = (tapX / width).clamp(0.0, 1.0);
    final seekPosition = widget.totalDuration * percentage;

    widget.onSeek!(seekPosition);
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Duration currentPosition;
  final Duration totalDuration;
  final Color waveColor;
  final Color playedColor;
  final Color playheadColor;
  final Duration? ghostPosition;
  final List<Duration>? slicerSegments;

  WaveformPainter({
    required this.waveformData,
    required this.currentPosition,
    required this.totalDuration,
    required this.waveColor,
    required this.playedColor,
    required this.playheadColor,
    this.ghostPosition,
    this.slicerSegments,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final playProgress = totalDuration.inMilliseconds > 0
        ? currentPosition.inMilliseconds / totalDuration.inMilliseconds
        : 0.0;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    // Draw waveform bars
    for (int i = 0; i < waveformData.length; i++) {
      final x = i * barWidth;
      // Ensure barHeight doesn't exceed bounds
      final barHeight = (waveformData[i] * (size.height * 0.8)).clamp(
        0.0,
        size.height,
      );

      // Determine color (played vs unplayed)
      final progress = i / waveformData.length;
      final color = progress <= playProgress ? playedColor : waveColor;

      final paint = Paint()
        ..color = color
        ..strokeWidth = barWidth * 0.8
        ..strokeCap = StrokeCap.round;

      // Draw bar from center
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }

    // Draw playhead
    final playheadX = size.width * playProgress;
    final playheadPaint = Paint()
      ..color = playheadColor
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, size.height),
      playheadPaint,
    );

    // Draw Slicer Segments (if active)
    if (slicerSegments != null &&
        slicerSegments!.isNotEmpty &&
        totalDuration.inMilliseconds > 0) {
      final slicePaint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final activeSlicePaint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < slicerSegments!.length; i++) {
        final start = slicerSegments![i];
        if (start.inMilliseconds > totalDuration.inMilliseconds) continue;

        final startProgress =
            start.inMilliseconds / totalDuration.inMilliseconds;
        final startX = size.width * startProgress;

        // Draw Line
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX, size.height),
          slicePaint,
        );

        // Highlight Active Slice
        if (i < slicerSegments!.length - 1) {
          final end = slicerSegments![i + 1];
          if (currentPosition >= start && currentPosition < end) {
            final endProgress =
                end.inMilliseconds / totalDuration.inMilliseconds;
            final endX = size.width * endProgress;
            canvas.drawRect(
              Rect.fromLTRB(startX, 0, endX, size.height),
              activeSlicePaint,
            );
          }
        }
      }
    }

    // Draw Ghost Playhead (if active)
    if (ghostPosition != null && totalDuration.inMilliseconds > 0) {
      final ghostProgress =
          ghostPosition!.inMilliseconds / totalDuration.inMilliseconds;
      final ghostX = size.width * ghostProgress;

      final ghostPaint = Paint()
        ..color = Colors.redAccent
            .withOpacity(0.8) // Distinct color for ghost
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(ghostX, 0),
        Offset(ghostX, size.height),
        ghostPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition ||
        oldDelegate.waveformData != waveformData ||
        oldDelegate.ghostPosition != ghostPosition ||
        oldDelegate.slicerSegments != slicerSegments;
  }
}
