import 'package:flutter/foundation.dart';

class AppState {
  AppState._();

  static final ValueNotifier<Map<String, dynamic>?> selectedHive =
      ValueNotifier<Map<String, dynamic>?>(null);

  static final ValueNotifier<String> apiaryName = ValueNotifier<String>(
    "Mi apiario",
  );

  static void select(Map<String, dynamic>? hive) {
    selectedHive.value = hive;
  }

  static String? get selectedId {
    return selectedHive.value?['id']?.toString();
  }

  static String get hiveName {
    final name = selectedHive.value?['name']?.toString();
    if (name == null || name.trim().isEmpty) return "Sin colmena";
    return name;
  }

  static String? get channelId {
    final channel = selectedHive.value?['channelId']?.toString().trim();
    if (channel == null || channel.isEmpty) return null;
    return channel;
  }
}