import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';

class HistoryChart extends StatelessWidget {
  final String title;
  final List<double> values;
  final Color color;
  final String unit;
  final String startLabel;
  final String endLabel;
  final bool showAsLine;

  const HistoryChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    required this.unit,
    required this.startLabel,
    required this.endLabel,
    this.showAsLine = true,
  });

  static const double plotHeight = 120;
  static const double labelHeight = 14;
  static const double labelWidth = 38;

  @override
  Widget build(BuildContext context) {
    double maxValue = values.first;
    double minValue = values.first;

    for (final value in values) {
      if (value > maxValue) maxValue = value;
      if (value < minValue) minValue = value;
    }

    final double dataRange = maxValue - minValue;
    final double margin = dataRange == 0 ? 1 : dataRange * 0.15;

    final double axisMax = maxValue + margin;
    double axisMin;

    if (showAsLine) {
      axisMin = minValue - margin;
      if (minValue >= 0 && axisMin < 0) axisMin = 0;
    } else {
      axisMin = 0;
    }

    final double axisRange = axisMax - axisMin;
    final double barArea = plotHeight - labelHeight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: MyTextStyles.label),
              Text(
                "${values.last.toStringAsFixed(1)} $unit actual",
                style: MyTextStyles.chip.copyWith(
                  color: MyColors.primaryStrong,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          SizedBox(
            height: plotHeight,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildGridLine(axisMax),
                    buildGridLine((axisMax + axisMin) / 2),
                    buildGridLine(axisMin),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: labelWidth + 8,
                    top: labelHeight / 2,
                    bottom: labelHeight / 2,
                  ),
                  child: showAsLine
                      ? SizedBox.expand(
                          child: CustomPaint(
                            painter: LineChartPainter(
                              values: values,
                              axisMin: axisMin,
                              axisMax: axisMax,
                              color: color,
                            ),
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final value in values)
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  height:
                                      ((value - axisMin) / axisRange) * barArea,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          Padding(
            padding: EdgeInsets.only(left: labelWidth + 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  startLabel,
                  style: MyTextStyles.chip.copyWith(
                    color: MyColors.secondaryText,
                  ),
                ),
                Text(
                  endLabel,
                  style: MyTextStyles.chip.copyWith(
                    color: MyColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGridLine(double value) {
    return SizedBox(
      height: labelHeight,
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              value.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: MyTextStyles.chip.copyWith(
                color: MyColors.secondaryText,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: MyColors.border)),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final double axisMin;
  final double axisMax;
  final Color color;

  LineChartPainter({
    required this.values,
    required this.axisMin,
    required this.axisMax,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final double range = axisMax - axisMin;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()..color = color;

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final double x = (i / (values.length - 1)) * size.width;
      final double y =
          size.height - ((values[i] - axisMin) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    if (values.length <= 30) {
      for (int i = 0; i < values.length; i++) {
        final double x = (i / (values.length - 1)) * size.width;
        final double y =
            size.height - ((values[i] - axisMin) / range) * size.height;
        canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}