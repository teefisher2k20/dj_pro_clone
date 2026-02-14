import 'package:flutter/material.dart';
import '../../../core/audio/effects_processor.dart';
import 'knob_widget.dart';

class FXPanelWidget extends StatelessWidget {
  final AudioEffectType currentEffect;
  final double wetDry;
  final bool isActive;
  final ValueChanged<AudioEffectType> onEffectChanged;
  final ValueChanged<double> onWetDryChanged;
  final ValueChanged<bool> onActiveChanged;
  final Color color;

  const FXPanelWidget({
    super.key,
    required this.currentEffect,
    required this.wetDry,
    required this.isActive,
    required this.onEffectChanged,
    required this.onWetDryChanged,
    required this.onActiveChanged,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Effect Selector
          DropdownButton<AudioEffectType>(
            value: currentEffect,
            dropdownColor: const Color(0xFF1A1F3A),
            style: const TextStyle(fontSize: 12, color: Colors.white),
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
            items: AudioEffectType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.label));
            }).toList(),
            onChanged: (val) {
              if (val != null) onEffectChanged(val);
            },
          ),

          const SizedBox(width: 16),

          // Wet/Dry Knob
          KnobWidget(
            value: wetDry,
            onChanged: onWetDryChanged,
            label: 'FX',
            color: isActive ? color : Colors.grey,
            size: 32,
          ),

          const SizedBox(width: 16),

          // Toggle Button
          GestureDetector(
            onTap: () => onActiveChanged(!isActive),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: isActive ? color : Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ON',
                style: TextStyle(
                  color: isActive ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
