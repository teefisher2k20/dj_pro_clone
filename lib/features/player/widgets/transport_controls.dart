import 'package:flutter/material.dart';

class TransportControls extends StatelessWidget {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onSeekEnd;

  const TransportControls({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
    required this.onSeekEnd,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Seek Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position),
              style: const TextStyle(color: Colors.white70),
            ),
            Expanded(
              child: Slider(
                value: position.inMilliseconds.toDouble(),
                min: 0.0,
                max: duration.inMilliseconds.toDouble() > 0
                    ? duration.inMilliseconds.toDouble()
                    : 1000.0, // Prevent division by zero
                onChanged: onSeek,
                onChangeEnd: onSeekEnd,
                activeColor: const Color(0xFF00D9FF),
                inactiveColor: Colors.white24,
              ),
            ),
            Text(
              _formatDuration(duration),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),

        // Controls Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.white70),
              iconSize: 32,
              onPressed: () {}, // Not implemented for single track
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white70),
              iconSize: 48,
              onPressed: onStop,
            ),
            IconButton(
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: const Color(0xFF00D9FF), // Neon blue for primary action
              ),
              iconSize: 64,
              onPressed: onPlayPause,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white70),
              iconSize: 32,
              onPressed: () {}, // Not implemented for single track
            ),
          ],
        ),
      ],
    );
  }
}
