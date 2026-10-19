import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zumbee_app/components/alert_card.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/services/alert_service.dart';
import 'package:zumbee_app/services/thingspeak_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;
  bool hasConnectionError = false;
  bool hasData = false;
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
      alerts = [];
      hasData = false;
    });
    loadData();
  }

  Future<void> loadData() async {
    final channel = AppState.channelId;

    if (channel == null) {
      if (!mounted) return;
      setState(() {
        alerts = [];
        hasData = false;
        isLoading = false;
        hasConnectionError = false;
      });
      return;
    }

    try {
      final readings = await ThingSpeakService(channel).getHistory();
      if (!mounted) return;
      setState(() {
        alerts = AlertService().analyze(readings);
        hasData = readings.isNotEmpty;
        isLoading = false;
        hasConnectionError = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasConnectionError = true;
      });
    }
  }

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: ZumbeeAppBar(showPerfil: true, isOnline: !hasConnectionError),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.primary))
          : RefreshIndicator(
              onRefresh: loadData,
              color: MyColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Alertas", style: MyTextStyles.screenTitle),
                    Text(
                      AppState.channelId == null
                          ? "Selecciona una colmena con nodo"
                          : "Estado de ${AppState.hiveName}",
                      style: MyTextStyles.bodySmall,
                    ),

                    SizedBox(height: 20),

                    if (AppState.channelId == null)
                      buildMessage(
                        icon: Icons.sensors_off,
                        title: "Sin nodo asignado",
                        body:
                            "Esta colmena no tiene canal de ThingSpeak. Asígnaselo desde el Apiario para empezar a vigilarla.",
                      )
                    else if (hasConnectionError)
                      buildMessage(
                        icon: Icons.wifi_off,
                        title: "No hay conexión",
                        body:
                            "No pudimos consultar las últimas lecturas. Lo reintentamos cada 20 segundos.",
                      )
                    else if (!hasData)
                      buildMessage(
                        icon: Icons.hourglass_empty,
                        title: "Todavía no hay lecturas",
                        body:
                            "Cuando el nodo publique su primera medición vas a ver aquí el estado de la colmena.",
                      )
                    else if (alerts.isEmpty)
                      buildMessage(
                        icon: Icons.verified_outlined,
                        title: "Todo en orden",
                        body:
                            "Temperatura, humedad y peso están dentro de los rangos esperados.",
                        color: MyColors.healthy,
                      )
                    else
                      for (final alert in alerts)
                        AlertCard(
                          severity: alert['severity'],
                          title: alert['title'],
                          body: alert['body'],
                          time: formatTime(alert['date']),
                        ),

                    SizedBox(height: 20),
                    Container(
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
                          Text("CÓMO SE CALCULAN", style: MyTextStyles.label),
                          SizedBox(height: 12),
                          buildRule(
                            "Temperatura de cría",
                            "${AlertService.minTemperature.toStringAsFixed(0)} – ${AlertService.maxTemperature.toStringAsFixed(0)} °C",
                          ),
                          buildRule(
                            "Humedad relativa",
                            "${AlertService.minHumidity.toStringAsFixed(0)} – ${AlertService.maxHumidity.toStringAsFixed(0)} %",
                          ),
                          buildRule(
                            "Caída de peso",
                            "máx. ${(AlertService.maxWeightDrop * 100).toStringAsFixed(0)} % entre lecturas",
                          ),
                          buildRule(
                            "Silencio del nodo",
                            "máx. ${AlertService.maxHoursWithoutData} h",
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Las alertas se derivan de los umbrales de la literatura apícola y son indicativas. No reemplazan la revisión en campo.",
                            style: MyTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildRule(String name, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(name, style: MyTextStyles.bodySmall)),
          Text(
            range,
            style: MyTextStyles.bodySmall.copyWith(
              color: MyColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessage({
    required IconData icon,
    required String title,
    required String body,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: MyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color ?? MyColors.secondaryText),
          SizedBox(height: 12),
          Text(title, style: MyTextStyles.subtitle, textAlign: TextAlign.center),
          SizedBox(height: 4),
          Text(body, style: MyTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
