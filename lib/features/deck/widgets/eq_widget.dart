import 'package:flutter/material.dart';
import 'knob_widget.dart';

class EQWidget extends StatelessWidget {
  final double high;
  final double mid;
  final double low;
  final ValueChanged<double> onHighChanged;
  final ValueChanged<double> onMidChanged;
  final ValueChanged<double> onLowChanged;
  final Color color;

  const EQWidget({
    super.key,
    required this.high,
    required this.mid,
    required this.low,
    required this.onHighChanged,
    required this.onMidChanged,
    required this.onLowChanged,
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
          const Text(
            'EQ',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              KnobWidget(
                value: high,
                onChanged: onHighChanged,
                label: 'HIGH',
                color: color,
                size: 40,
              ),
              KnobWidget(
                value: mid,
                onChanged: onMidChanged,
                label: 'MID',
                color: color,
                size: 40,
              ),
              KnobWidget(
                value: low,
                onChanged: onLowChanged,
                label: 'LOW',
                color: color,
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
