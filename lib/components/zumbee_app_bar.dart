import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/profile_screen.dart';

class ZumbeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showPerfil;
  final bool? isOnline;

  const ZumbeeAppBar({super.key, required this.showPerfil, this.isOnline});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MyColors.background,
      scrolledUnderElevation: 0,
      elevation: 0,
      shadowColor: Colors.transparent,

      title: Row(
        children: [
          SizedBox(width: 4),
          Container(
            decoration: BoxDecoration(
              color: MyColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.emoji_nature_rounded, size: 35),
          ),
          SizedBox(width: 8),
          Text("Zum-Bee", style: MyTextStyles.zumBeeBrand),
        ],
      ),
      actions: [
        if (isOnline != null)
          Center(
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isOnline!
                    ? MyColors.primarySoft
                    : MyColors.criticalSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOnline! ? MyColors.border : MyColors.critical,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle_rounded,
                    size: 10,
                    color: isOnline!
                        ? MyColors.primaryStrong
                        : MyColors.criticalStrong,
                  ),
                  SizedBox(width: 6),
                  Text(
                    isOnline! ? "ONLINE" : "OFFLINE",
                    style: MyTextStyles.chip.copyWith(
                      color: isOnline!
                          ? MyColors.primaryStrong
                          : MyColors.criticalStrong,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (showPerfil)
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      color: MyColors.primary,
                      size: 26,
                    ),
                    Text(
                      "Perfil",
                      style: MyTextStyles.chip.copyWith(
                        color: MyColors.primaryStrong,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(width: 12),
      ],
    );
  }
}