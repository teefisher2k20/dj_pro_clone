import 'package:flutter/material.dart';

class StemControlsWidget extends StatelessWidget {
  final double vocals;
  final double drums;
  final double harmonics;
  final double other;
  final ValueChanged<double> onVocalsChanged;
  final ValueChanged<double> onDrumsChanged;
  final ValueChanged<double> onHarmonicsChanged;
  final ValueChanged<double> onOtherChanged;
  final Color color;

  const StemControlsWidget({
    super.key,
    required this.vocals,
    required this.drums,
    required this.harmonics,
    required this.other,
    required this.onVocalsChanged,
    required this.onDrumsChanged,
    required this.onHarmonicsChanged,
    required this.onOtherChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEURAL MIX',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStemSlider('VOCALS', vocals, onVocalsChanged),
              _buildStemSlider('DRUMS', drums, onDrumsChanged),
              _buildStemSlider('HARM.', harmonics, onHarmonicsChanged),
              _buildStemSlider('OTHER', other, onOtherChanged),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStemSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: color,
                inactiveTrackColor: Colors.black45,
                thumbColor: Colors.white,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
