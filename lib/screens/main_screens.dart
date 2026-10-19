import 'package:flutter/material.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/alerts_screen.dart';
import 'package:zumbee_app/screens/apiary_screen.dart';
import 'package:zumbee_app/screens/begin_screen.dart';
import 'package:zumbee_app/screens/history_screen.dart';
import 'package:zumbee_app/services/database_service.dart';

class MainScreens extends StatefulWidget {
  const MainScreens({super.key});

  @override
  State<MainScreens> createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  int myIndex = 0;

  final screens = const [
    BeginScreen(),
    HistoryScreen(),
    AlertsScreen(),
    ApiaryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    selectInitialHive();
  }

  Future<void> selectInitialHive() async {
    if (AppState.selectedId != null) return;

    try {
      final hives = await DatabaseService().getHives();
      if (hives.isEmpty) return;

      Map<String, dynamic> chosen = hives.first;
      for (final hive in hives) {
        final channel = hive['channelId']?.toString().trim() ?? '';
        if (channel.isNotEmpty) {
          chosen = hive;
          break;
        }
      }

      AppState.select(chosen);
    } catch (error) {
      return;
    }
  }

  void changeScreen(int i) {
    setState(() => myIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: myIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: MyColors.surface,
        indicatorColor: MyColors.primarySoft,
        selectedIndex: myIndex,
        onDestinationSelected: changeScreen,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return MyTextStyles.navLabel.copyWith(
            color: active ? MyColors.primaryStrong : MyColors.primary,
          );
        }),

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: MyColors.primary),
            selectedIcon: Icon(Icons.home, color: MyColors.primaryStrong),
            label: "Inicio",
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: MyColors.primary),
            selectedIcon: Icon(
              Icons.calendar_month,
              color: MyColors.primaryStrong,
            ),
            label: "Historial",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.notifications_outlined,
              color: MyColors.primary,
            ),
            selectedIcon: Icon(
              Icons.notifications,
              color: MyColors.primaryStrong,
            ),
            label: "Alertas",
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on, color: MyColors.primary),
            selectedIcon: Icon(Icons.grid_view, color: MyColors.primaryStrong),
            label: "Apiario",
          ),
        ],
      ),
    );
  }
}