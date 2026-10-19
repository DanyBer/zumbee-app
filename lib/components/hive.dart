import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';

class Hive extends StatelessWidget {
  final String name;
  final String location;
  final String hiveType;
  final String nodeIdentifier;
  final String channelId;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const Hive({
    super.key,
    required this.name,
    required this.location,
    required this.hiveType,
    required this.nodeIdentifier,
    required this.channelId,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNode = channelId.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 12,
            bottom: 4,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? MyColors.primarySoft : MyColors.surface,
            border: Border.all(
              color: isSelected ? MyColors.primary : MyColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: MyTextStyles.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: hasNode ? MyColors.healthySoft : MyColors.border,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        hasNode ? "CON NODO" : "SIN NODO",
                        style: MyTextStyles.chip.copyWith(
                          color: hasNode
                              ? MyColors.healthy
                              : MyColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$hiveType · $location",
                          style: MyTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          hasNode ? "Canal $channelId" : "Sin canal asignado",
                          style: MyTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: MyColors.secondaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: MyColors.criticalStrong,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}