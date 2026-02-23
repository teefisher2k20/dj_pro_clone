import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crossfader_widget.dart';
import 'eq_widget.dart';
import 'gain_control_widget.dart';

class MixerWidget extends StatelessWidget {
  final double crossfaderPosition;
  final ValueChanged<double> onCrossfaderChanged;
  final double masterVolume;
  final ValueChanged<double> onMasterVolumeChanged;
  final bool isSmartFaderActive;
  final VoidCallback onToggleSmartFader;

  // Deck A Controls
  final double deckAGain;
  final ValueChanged<double> onDeckAGainChanged;
  final double deckAHighEq;
  final ValueChanged<double> onDeckAHighEqChanged;
  final double deckAMidEq;
  final ValueChanged<double> onDeckAMidEqChanged;
  final double deckALowEq;
  final ValueChanged<double> onDeckALowEqChanged;
  final double deckAColorFx;
  final ValueChanged<double> onDeckAColorFxChanged;
  final double deckAVolume;
  final ValueChanged<double> onDeckAVolumeChanged;

  // Deck B Controls
  final double deckBGain;
  final ValueChanged<double> onDeckBGainChanged;
  final double deckBHighEq;
  final ValueChanged<double> onDeckBHighEqChanged;
  final double deckBMidEq;
  final ValueChanged<double> onDeckBMidEqChanged;
  final double deckBLowEq;
  final ValueChanged<double> onDeckBLowEqChanged;
  final double deckBColorFx;
  final ValueChanged<double> onDeckBColorFxChanged;
  final double deckBVolume;
  final ValueChanged<double> onDeckBVolumeChanged;

  const MixerWidget({
    super.key,
    required this.crossfaderPosition,
    required this.onCrossfaderChanged,
    required this.masterVolume,
    required this.onMasterVolumeChanged,
    required this.isSmartFaderActive,
    required this.onToggleSmartFader,
    required this.deckAGain,
    required this.onDeckAGainChanged,
    required this.deckAHighEq,
    required this.onDeckAHighEqChanged,
    required this.deckAMidEq,
    required this.onDeckAMidEqChanged,
    required this.deckALowEq,
    required this.onDeckALowEqChanged,
    required this.deckAColorFx,
    required this.onDeckAColorFxChanged,
    required this.deckAVolume,
    required this.onDeckAVolumeChanged,
    required this.deckBGain,
    required this.onDeckBGainChanged,
    required this.deckBHighEq,
    required this.onDeckBHighEqChanged,
    required this.deckBMidEq,
    required this.onDeckBMidEqChanged,
    required this.deckBLowEq,
    required this.onDeckBLowEqChanged,
    required this.deckBColorFx,
    required this.onDeckBColorFxChanged,
    required this.deckBVolume,
    required this.onDeckBVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Expanded width for 3 strips
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1118),
        border: Border(
          left: BorderSide(color: Colors.white10),
          right: BorderSide(color: Colors.white10),
        ),
      ),
      child: Column(
        children: [
          // Mixer Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Channel A
                Expanded(
                  child: _buildChannelStrip(
                    label: 'CH 1',
                    gain: deckAGain,
                    onGainChanged: onDeckAGainChanged,
                    high: deckAHighEq,
                    onHighChanged: onDeckAHighEqChanged,
                    mid: deckAMidEq,
                    onMidChanged: onDeckAMidEqChanged,
                    low: deckALowEq,
                    onLowChanged: onDeckALowEqChanged,
                    colorFx: deckAColorFx,
                    onColorFxChanged: onDeckAColorFxChanged,
                    volume: deckAVolume,
                    onVolumeChanged: onDeckAVolumeChanged,
                    color: Colors.cyanAccent,
                  ),
                ),

                // Master Section
                SizedBox(
                  width: 60,
                  child: Column(
                    children: [
                      const Text(
                        'MASTER',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Master Knob
                      _buildKnob(
                        value: masterVolume,
                        onChanged: onMasterVolumeChanged,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      // Meters
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildVuMeter(deckAMidEq), // Simulated level
                            const SizedBox(width: 4),
                            _buildVuMeter(deckBMidEq), // Simulated level
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Smart Fader Toggle
                      IconButton(
                        icon: Icon(
                          Icons.auto_fix_high,
                          color: isSmartFaderActive
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        onPressed: onToggleSmartFader,
                      ),
                    ],
                  ),
                ),

                // Channel B
                Expanded(
                  child: _buildChannelStrip(
                    label: 'CH 2',
                    gain: deckBGain,
                    onGainChanged: onDeckBGainChanged,
                    high: deckBHighEq,
                    onHighChanged: onDeckBHighEqChanged,
                    mid: deckBMidEq,
                    onMidChanged: onDeckBMidEqChanged,
                    low: deckBLowEq,
                    onLowChanged: onDeckBLowEqChanged,
                    colorFx: deckBColorFx,
                    onColorFxChanged: onDeckBColorFxChanged,
                    volume: deckBVolume,
                    onVolumeChanged: onDeckBVolumeChanged,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Crossfader
          SizedBox(
            height: 50,
            child: CrossfaderWidget(
              position: crossfaderPosition,
              onChanged: onCrossfaderChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelStrip({
    required String label,
    required double gain,
    required ValueChanged<double> onGainChanged,
    required double high,
    required ValueChanged<double> onHighChanged,
    required double mid,
    required ValueChanged<double> onMidChanged,
    required double low,
    required ValueChanged<double> onLowChanged,
    required double colorFx,
    required ValueChanged<double> onColorFxChanged,
    required double volume,
    required ValueChanged<double> onVolumeChanged,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // TRIM
        _buildKnob(
          value: gain,
          onChanged: onGainChanged,
          label: 'TRIM',
          color: Colors.grey,
        ),
        const SizedBox(height: 12),

        // HIG
        _buildKnob(
          value: high,
          onChanged: onHighChanged,
          label: 'HI',
          color: Colors.grey,
        ),
        const SizedBox(height: 8),

        // MID
        _buildKnob(
          value: mid,
          onChanged: onMidChanged,
          label: 'MID',
          color: Colors.grey,
        ),
        const SizedBox(height: 8),

        // LOW
        _buildKnob(
          value: low,
          onChanged: onLowChanged,
          label: 'LOW',
          color: Colors.grey,
        ),

        const SizedBox(height: 16),

        // COLOR FX
        _buildKnob(
          value: colorFx,
          onChanged: onColorFxChanged,
          label: 'COLOR',
          size: 40,
          color: color,
        ),

        const SizedBox(height: 16),

        // Channel Fader
        Expanded(
          child: Container(
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white10),
            ),
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  activeTrackColor: color,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(value: volume, onChanged: onVolumeChanged),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKnob({
    required double value,
    required ValueChanged<double> onChanged,
    String? label,
    double size = 32,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            double newValue = (value - details.primaryDelta! / 100).clamp(
              0.0,
              1.0,
            );
            onChanged(newValue);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2E3B),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Transform.rotate(
                    angle: (value - 0.5) * 4.5, // Map 0..1 to rotation
                    child: Container(
                      width: 4,
                      height: size * 0.5,
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 2,
                        height: size * 0.3,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVuMeter(double level) {
    return Container(
      width: 8,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        heightFactor:
            0.2 + (level * 0.6), // Simulated level based on EQ knob for now
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.green, Colors.green, Colors.yellow, Colors.red],
              stops: [0.0, 0.6, 0.8, 1.0],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
