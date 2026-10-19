import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mytextstyles.dart';

class MetricGauge extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String unit;
  final String label;
  final Color color;
  final Color softColor;

  const MetricGauge({
    super.key,

    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.label,
    required this.color,
    required this.softColor,
  });

  @override
  State<MetricGauge> createState() => _MetricGaugeState();
}

class _MetricGaugeState extends State<MetricGauge> {
  @override
  Widget build(BuildContext context) {
    final double progress =
        ((widget.value - widget.min) / (widget.max - widget.min));
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 75,
              height: 75,
              child: CircularProgressIndicator(
                backgroundColor: widget.softColor,
                value: progress,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                color: widget.color,
              ),
            ),
            Column(
              children: [
                Text(widget.value.toString(), style: MyTextStyles.metricValue),
                Text(widget.unit, style: MyTextStyles.label),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(widget.label, style: MyTextStyles.bodySmall),
      ],
    );
  }
}
