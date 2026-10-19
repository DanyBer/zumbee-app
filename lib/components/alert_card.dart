import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';

class AlertCard extends StatelessWidget {
  final String severity;
  final String title;
  final String body;
  final String time;

  const AlertCard({
    super.key,
    required this.severity,
    required this.title,
    required this.body,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical = severity == 'critical';

    final Color softColor = isCritical
        ? MyColors.criticalSoft
        : MyColors.primarySoft;
    final Color strongColor = isCritical
        ? MyColors.criticalStrong
        : MyColors.primaryStrong;
    final Color borderColor = isCritical
        ? MyColors.critical
        : MyColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: softColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCritical ? Icons.error_outline : Icons.warning_amber_rounded,
              color: strongColor,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: MyTextStyles.alertTitle.copyWith(
                            color: strongColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        time,
                        style: MyTextStyles.chip.copyWith(color: strongColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    body,
                    style: MyTextStyles.alertBody.copyWith(
                      color: MyColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
