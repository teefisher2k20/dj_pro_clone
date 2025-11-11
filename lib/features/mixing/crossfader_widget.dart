import 'package:flutter/material.dart';

/// Calculates the volume for a deck based on crossfader position
/// 
/// [crossfaderPosition]: -1.0 (full Deck A) to 1.0 (full Deck B)
/// [isDeckA]: true for Deck A, false for Deck B
/// 
/// Returns volume level from 0.0 to 1.0
double calculateDeckVolume(double crossfaderPosition, bool isDeckA) {
  if (isDeckA) {
    return crossfaderPosition <= 0 ? 1.0 : 1.0 - crossfaderPosition;
  } else {
    return crossfaderPosition >= 0 ? 1.0 : 1.0 + crossfaderPosition;
  }
}

/// Widget for the DJ crossfader control
class CrossfaderWidget extends StatefulWidget {
  final double initialPosition;
  final ValueChanged<double> onChanged;

  const CrossfaderWidget({
    super.key,
    this.initialPosition = 0.0,
    required this.onChanged,
  });

  @override
  State<CrossfaderWidget> createState() => _CrossfaderWidgetState();
}

class _CrossfaderWidgetState extends State<CrossfaderWidget> {
  late double _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'A',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _position <= 0 ? Colors.blue : Colors.grey,
              ),
            ),
            Text(
              'B',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _position >= 0 ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: Colors.deepPurple,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: _position,
            min: -1.0,
            max: 1.0,
            onChanged: (value) {
              setState(() {
                _position = value;
              });
              widget.onChanged(value);
            },
          ),
        ),
        Text(
          'Crossfader',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
