import 'package:flutter/material.dart';

class CrossfaderWidget extends StatelessWidget {
  final double position;
  final ValueChanged<double> onChanged;
  const CrossfaderWidget({
    super.key,
    required this.position,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.all(16), // Reduced padding for compact use
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Compact
        children: [
          // Crossfader slider
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 8,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: position,
              onChanged: onChanged,
              min: -1.0,
              max: 1.0,
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
            ),
          ),

          // Labels A/B
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'A',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'B',
                  style: TextStyle(
                    color: Color(0xFFFF8000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
