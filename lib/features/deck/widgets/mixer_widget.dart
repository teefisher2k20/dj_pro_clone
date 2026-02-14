import 'package:flutter/material.dart';
import 'crossfader_widget.dart';

class MixerWidget extends StatelessWidget {
  final double crossfaderPosition;
  final ValueChanged<double> onCrossfaderChanged;
  final double masterVolume;
  final ValueChanged<double> onMasterVolumeChanged;
  final bool isSmartFaderActive;
  final VoidCallback onToggleSmartFader;

  const MixerWidget({
    super.key,
    required this.crossfaderPosition,
    required this.onCrossfaderChanged,
    required this.masterVolume,
    required this.onMasterVolumeChanged,
    required this.isSmartFaderActive,
    required this.onToggleSmartFader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Fixed width mixer strip
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        border: Border(
          left: BorderSide(color: Colors.white10),
          right: BorderSide(color: Colors.white10),
        ),
      ),
      child: Column(
        children: [
          // Master Volume Label
          const Text(
            'MASTER',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),

          // Smart Fader Toggle
          IconButton(
            icon: Icon(
              Icons.auto_fix_high,
              color: isSmartFaderActive ? Colors.blueAccent : Colors.grey,
              size: 20,
            ),
            tooltip: 'Smart Fader',
            onPressed: onToggleSmartFader,
          ),

          const SizedBox(height: 8),

          // Master Volume Slider
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: masterVolume,
                onChanged: onMasterVolumeChanged,
                activeColor: Colors.white,
                inactiveColor: Colors.black45,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Placeholder for VU Meters
          Container(
            height: 100,
            width: 40,
            color: Colors.black26,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVuMeter(),
                const SizedBox(width: 4),
                _buildVuMeter(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Crossfader
          SizedBox(
            height: 60,
            child: CrossfaderWidget(
              position: crossfaderPosition,
              onChanged: onCrossfaderChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVuMeter() {
    return Container(
      width: 6,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 6,
        height: 60 + (30 * (masterVolume * 0.5)), // Simulated bounce
        color: Colors.green,
      ),
    );
  }
}
