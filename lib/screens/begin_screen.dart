import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zumbee_app/components/Metric_Gauge.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/apiary_screen.dart';
import 'package:zumbee_app/services/database_service.dart';
import 'package:zumbee_app/services/thingspeak_service.dart';

class BeginScreen extends StatefulWidget {
  const BeginScreen({super.key});

  @override
  State<BeginScreen> createState() => _BeginScreenState();
}

class _BeginScreenState extends State<BeginScreen> {
  Map<String, dynamic>? reading;
  bool isLoading = true;
  bool hasConnectionError = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    AppState.selectedHive.addListener(onHiveChanged);
    AppState.apiaryName.addListener(onApiaryChanged);
    loadData();
    loadApiaryName();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (timer) => loadData(),
    );
  }

  @override
  void dispose() {
    AppState.selectedHive.removeListener(onHiveChanged);
    AppState.apiaryName.removeListener(onApiaryChanged);
    refreshTimer?.cancel();
    super.dispose();
  }

  void onHiveChanged() {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      reading = null;
    });
    loadData();
  }

  void onApiaryChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> loadApiaryName() async {
    try {
      final profile = await DatabaseService().getUserProfile();
      if (!mounted || profile == null) return;
      final apiary = profile['apiaryName']?.toString();
      if (apiary != null && apiary.isNotEmpty) {
        AppState.apiaryName.value = apiary;
      }
    } catch (error) {
      return;
    }
  }

  Future<void> loadData() async {
    final channel = AppState.channelId;

    if (channel == null) {
      if (!mounted) return;
      setState(() {
        reading = null;
        isLoading = false;
        hasConnectionError = false;
      });
      return;
    }

    try {
      final result = await ThingSpeakService(channel).getHistory(results: 1);
      if (!mounted) return;
      setState(() {
        reading = result.isEmpty ? null : result.last;
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

  Future<void> refreshAll() async {
    await loadData();
    await loadApiaryName();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChannel = AppState.channelId != null;

    String age = "sin datos";
    if (reading != null) {
      final minutes = DateTime.now().difference(reading!['date']).inMinutes;
      if (minutes < 1) {
        age = "hace un momento";
      } else if (minutes < 60) {
        age = "hace $minutes min";
      } else if (minutes < 1440) {
        age = "hace ${minutes ~/ 60} h";
      } else {
        age = "hace ${minutes ~/ 1440} d";
      }
    }

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: ZumbeeAppBar(
        showPerfil: true,
        isOnline: hasChannel ? !hasConnectionError : null,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.primary))
          : RefreshIndicator(
              onRefresh: refreshAll,
              color: MyColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Inicio", style: MyTextStyles.screenTitle),
                    Text(
                      "Lectura en vivo de tu colmena",
                      style: MyTextStyles.bodySmall,
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MyColors.border),
                        color: MyColors.surfaceDark,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppState.apiaryName.value,
                                    style: MyTextStyles.subtitleDark,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    hasChannel
                                        ? "${AppState.hiveName} · $age"
                                        : AppState.hiveName,
                                    style: MyTextStyles.bodySmallDark,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApiaryScreen(),
                                  ),
                                );
                                loadApiaryName();
                              },
                              icon: Icon(
                                Icons.chevron_right,
                                color: MyColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MyColors.border),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16,
                          right: 8,
                          left: 8,
                          bottom: 16,
                        ),
                        child: reading == null
                            ? Column(
                                children: [
                                  Icon(
                                    !hasChannel
                                        ? Icons.sensors_off
                                        : hasConnectionError
                                        ? Icons.wifi_off
                                        : Icons.hourglass_empty,
                                    size: 32,
                                    color: MyColors.secondaryText,
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      !hasChannel
                                          ? "Esta colmena no tiene nodo. Asígnale un canal desde el Apiario."
                                          : hasConnectionError
                                          ? "No hay conexión con ThingSpeak"
                                          : "El nodo todavía no ha enviado lecturas",
                                      style: MyTextStyles.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (hasChannel)
                                    TextButton(
                                      onPressed: () {
                                        setState(() => isLoading = true);
                                        loadData();
                                      },
                                      child: Text(
                                        "Reintentar",
                                        style: MyTextStyles.link,
                                      ),
                                    ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MetricGauge(
                                        value: reading!['temperature'],
                                        min: 30,
                                        max: 40,
                                        unit: "°C",
                                        label: "Temperatura",
                                        color: MyColors.cold,
                                        softColor: MyColors.coldSoft,
                                      ),
                                      MetricGauge(
                                        value: reading!['weight'],
                                        min: 0,
                                        max: 85,
                                        unit: "kg",
                                        label: "Peso Colmena",
                                        color: MyColors.primary,
                                        softColor: MyColors.primarySoft,
                                      ),
                                      MetricGauge(
                                        value: reading!['humidity'],
                                        min: 40,
                                        max: 80,
                                        unit: "% HR",
                                        label: "Humedad",
                                        color: MyColors.healthy,
                                        softColor: MyColors.healthySoft,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    hasConnectionError
                                        ? "Sin conexión · última lectura $age"
                                        : "Última lectura $age",
                                    style: MyTextStyles.bodySmall.copyWith(
                                      color: hasConnectionError
                                          ? MyColors.critical
                                          : MyColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: MyColors.border),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 16,
                          right: 16,
                          bottom: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("CONTROL TÉRMICO", style: MyTextStyles.label),

                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 64,
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        MyColors.criticalSoft,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: MyColors.critical,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_outlined,
                                          color: MyColors.criticalStrong,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Calentar",
                                          style: MyTextStyles.button.copyWith(
                                            color: MyColors.criticalStrong,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 64,
                                  width: 150,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        MyColors.coldSoft,
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: BorderSide(
                                            color: MyColors.cold,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.ac_unit_outlined,
                                          color: MyColors.coldStrong,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Enfriar",
                                          style: MyTextStyles.button.copyWith(
                                            color: MyColors.coldStrong,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                            Text(
                              "La activación solo dura 20 minutos, para no alterar a la colmena y generar enjambrazones.",
                              style: MyTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}