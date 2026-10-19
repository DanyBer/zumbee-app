import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zumbee_app/components/history_chart.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/thingspeak_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;
  bool hasConnectionError = false;
  DateTime? lastUpdate;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    AppState.selectedHive.addListener(onHiveChanged);
    loadData();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (timer) => loadData(),
    );
  }

  @override
  void dispose() {
    AppState.selectedHive.removeListener(onHiveChanged);
    refreshTimer?.cancel();
    super.dispose();
  }

  void onHiveChanged() {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      data = [];
      lastUpdate = null;
    });
    loadData();
  }

  Future<void> loadData() async {
    final channel = AppState.channelId;

    if (channel == null) {
      if (!mounted) return;
      setState(() {
        data = [];
        isLoading = false;
        hasConnectionError = false;
      });
      return;
    }

    try {
      final result = await ThingSpeakService(channel).getHistory();
      if (!mounted) return;
      setState(() {
        data = result;
        isLoading = false;
        hasConnectionError = false;
        lastUpdate = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasConnectionError = true;
      });
    }
  }

  String buildStatusText() {
    if (lastUpdate == null) {
      return "Historial de ${AppState.hiveName}";
    }
    if (hasConnectionError) {
      return "Sin conexión · último dato ${formatTime(lastUpdate!)}";
    }
    return "${AppState.hiveName} · actualizado a las ${formatTime(lastUpdate!)}";
  }

  String formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChannel = AppState.channelId != null;

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: ZumbeeAppBar(
        showPerfil: true,
        isOnline: hasChannel ? !hasConnectionError : null,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: MyColors.primary));
    }

    if (data.isEmpty) {
      final bool hasChannel = AppState.channelId != null;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                !hasChannel
                    ? Icons.sensors_off
                    : hasConnectionError
                    ? Icons.wifi_off
                    : Icons.hourglass_empty,
                size: 40,
                color: MyColors.secondaryText,
              ),
              SizedBox(height: 12),
              Text(
                !hasChannel
                    ? "Esta colmena no tiene nodo. Asígnale un canal desde el Apiario."
                    : hasConnectionError
                    ? "No hay conexión con ThingSpeak"
                    : "El nodo todavía no ha enviado lecturas",
                style: MyTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              if (hasChannel)
                TextButton(
                  onPressed: () {
                    setState(() => isLoading = true);
                    loadData();
                  },
                  child: Text("Reintentar", style: MyTextStyles.link),
                ),
            ],
          ),
        ),
      );
    }

    final List<double> temperatures = [];
    final List<double> humidities = [];
    final List<double> weights = [];

    for (final reading in data) {
      temperatures.add(reading['temperature']);
      humidities.add(reading['humidity']);
      weights.add(reading['weight']);
    }

    final DateTime firstDate = data.first['date'];
    final DateTime lastDate = data.last['date'];

    final String firstDay = formatDate(firstDate);
    final String lastDay = formatDate(lastDate);
    final String dateRange = firstDay == lastDay
        ? firstDay
        : "$firstDay – $lastDay";

    return RefreshIndicator(
      onRefresh: loadData,
      color: MyColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Historial", style: MyTextStyles.screenTitle),
            Text(
              buildStatusText(),
              style: MyTextStyles.bodySmall.copyWith(
                color: hasConnectionError
                    ? MyColors.critical
                    : MyColors.secondaryText,
              ),
            ),

            SizedBox(height: 16),
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: MyColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: MyColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 15,
                    color: MyColors.secondaryText,
                  ),
                  SizedBox(width: 8),
                  Text(
                    dateRange,
                    style: MyTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MyColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
            HistoryChart(
              title: "TEMPERATURA (°C)",
              values: temperatures,
              color: MyColors.cold,
              unit: "°C",
              startLabel: formatTime(firstDate),
              endLabel: formatTime(lastDate),
            ),

            SizedBox(height: 12),
            HistoryChart(
              title: "HUMEDAD (% HR)",
              values: humidities,
              color: MyColors.healthy,
              unit: "%",
              startLabel: formatTime(firstDate),
              endLabel: formatTime(lastDate),
            ),

            SizedBox(height: 12),
            HistoryChart(
              title: "PESO COLMENA (KG)",
              values: weights,
              color: MyColors.primary,
              unit: "kg",
              startLabel: formatTime(firstDate),
              endLabel: formatTime(lastDate),
            ),
          ],
        ),
      ),
    );
  }
}