import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zumbee_app/components/hive.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/create_hive.dart';
import 'package:zumbee_app/services/database_service.dart';

class ApiaryScreen extends StatefulWidget {
  const ApiaryScreen({super.key});

  @override
  State<ApiaryScreen> createState() => _ApiaryScreenState();
}

class _ApiaryScreenState extends State<ApiaryScreen> {
  @override
  void initState() {
    super.initState();
    AppState.selectedHive.addListener(onSelectionChanged);
    AppState.apiaryName.addListener(onSelectionChanged);
    loadApiaryName();
  }

  @override
  void dispose() {
    AppState.selectedHive.removeListener(onSelectionChanged);
    AppState.apiaryName.removeListener(onSelectionChanged);
    super.dispose();
  }

  void onSelectionChanged() {
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

  Future<void> confirmDelete(String hiveId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MyColors.surface,
        title: Text("Eliminar colmena", style: MyTextStyles.subtitle),
        content: Text(
          "¿Seguro que quieres eliminar $name? Esta acción no se puede deshacer.",
          style: MyTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text("Cancelar", style: MyTextStyles.bodySmall),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              "Eliminar",
              style: MyTextStyles.bodySmall.copyWith(
                color: MyColors.criticalStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await DatabaseService().deleteHive(hiveId);

    if (AppState.selectedId == hiveId) {
      AppState.select(null);
    }
  }

  void openForm({Map<String, dynamic>? hive}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateHive(hive: hive)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.primary,
        onPressed: () => openForm(),
        child: Icon(Icons.add, color: MyColors.surfaceDark, size: 35),
      ),
      appBar: ZumbeeAppBar(showPerfil: true),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DatabaseService().hivesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: MyColors.primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Apiario", style: MyTextStyles.screenTitle),
                Text(
                  "Toca una colmena para verla en las demás pantallas.",
                  style: MyTextStyles.bodySmall,
                ),
                Text(
                  docs.length == 1
                      ? "1 colmena registrada"
                      : "${docs.length} colmenas registradas",
                  style: MyTextStyles.bodySmall,
                ),

                SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MyColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Apiario activo",
                          style: MyTextStyles.bodySmallDark,
                        ),
                        Text(
                          AppState.apiaryName.value,
                          style: MyTextStyles.subtitleDark,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.grid_view,
                            size: 40,
                            color: MyColors.secondaryText,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Todavía no tienes colmenas",
                            style: MyTextStyles.subtitle,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Usa el botón + para registrar la primera.",
                            style: MyTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                for (final doc in docs)
                  Hive(
                    name: doc.data()['name']?.toString() ?? "Sin nombre",
                    location: doc.data()['location']?.toString() ?? "",
                    hiveType: doc.data()['hiveType']?.toString() ?? "",
                    nodeIdentifier:
                        doc.data()['nodeIdentifier']?.toString() ?? "",
                    channelId: doc.data()['channelId']?.toString() ?? "",
                    isSelected: AppState.selectedId == doc.id,
                    onTap: () {
                      final data = doc.data();
                      data['id'] = doc.id;
                      AppState.select(data);
                    },
                    onEdit: () {
                      final data = doc.data();
                      data['id'] = doc.id;
                      openForm(hive: data);
                    },
                    onDelete: () => confirmDelete(
                      doc.id,
                      doc.data()['name']?.toString() ?? "esta colmena",
                    ),
                  ),

                SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }
}