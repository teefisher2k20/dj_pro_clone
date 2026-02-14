import 'package:flutter/material.dart';
import 'knob_widget.dart';

class GainControlWidget extends StatelessWidget {
  final double gain;
  final ValueChanged<double> onChanged;
  final Color color;

  const GainControlWidget({
    super.key,
    required this.gain,
    required this.onChanged,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KnobWidget(
            value: gain,
            onChanged: onChanged,
            label: 'GAIN',
            color: color,
            size: 32, // Smaller knob
          ),
        ],
      ),
    );
  }
}
