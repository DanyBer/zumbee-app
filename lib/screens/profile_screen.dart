import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zumbee_app/components/zumbee_app_bar.dart';
import 'package:zumbee_app/core/app_state.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/edit_profile.dart';
import 'package:zumbee_app/services/auth_service.dart';
import 'package:zumbee_app/services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> hives = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final userProfile = await DatabaseService().getUserProfile();
      final userHives = await DatabaseService().getHives();
      if (!mounted) return;

      final apiary = userProfile?['apiaryName']?.toString();
      if (apiary != null && apiary.isNotEmpty) {
        AppState.apiaryName.value = apiary;
      }

      setState(() {
        profile = userProfile;
        hives = userHives;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> onLogout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> onResetPassword() async {
    final email = AuthService().currentUser?.email;
    if (email == null) return;

    final error = await AuthService().sendPasswordReset(email);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error == null
            ? MyColors.healthyStrong
            : MyColors.criticalStrong,
        content: Text(
          error ?? "Te enviamos un correo a $email para cambiarla",
          style: MyTextStyles.bodySmall.copyWith(
            color: MyColors.primaryTextOnDark,
          ),
        ),
      ),
    );
  }

  Widget buildRow({
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
    BorderRadius? radius,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: MyColors.surface,
          border: Border.all(color: MyColors.border),
          borderRadius: radius,
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              Text(label, style: MyTextStyles.body),
              Spacer(),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = profile?['name'] ?? "Sin nombre";
    final String email =
        profile?['email'] ?? AuthService().currentUser?.email ?? "";
    final String apiaryName = profile?['apiaryName'] ?? "Sin apiario";

    int activeNodes = 0;
    for (final hive in hives) {
      final node = hive['nodeIdentifier']?.toString() ?? '';
      if (node.isNotEmpty) activeNodes++;
    }

    String measuringDays = "—";
    final createdAt = profile?['createdAt'];
    if (createdAt is Timestamp) {
      final days = DateTime.now().difference(createdAt.toDate()).inDays;
      measuringDays = days == 0 ? "Hoy" : "$days d";
    }

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: ZumbeeAppBar(showPerfil: false),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: MyColors.primary))
          : RefreshIndicator(
              onRefresh: loadData,
              color: MyColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Mi perfil", style: MyTextStyles.screenTitle),
                    Text(
                      "Cuenta, seguridad y conexión al nodo",
                      style: MyTextStyles.bodySmall,
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MyColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 32,
                          bottom: 32,
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/images/logo_full.png",
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: MyTextStyles.subtitleDark,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    email,
                                    style: MyTextStyles.bodySmallDark,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    apiaryName,
                                    style: MyTextStyles.bodySmallDark.copyWith(
                                      color: MyColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.surface,
                              border: Border.all(color: MyColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${hives.length}",
                                    style: MyTextStyles.metricValue,
                                  ),
                                  Text(
                                    "Colmenas",
                                    style: MyTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.surface,
                              border: Border.all(color: MyColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$activeNodes",
                                    style: MyTextStyles.metricValue,
                                  ),
                                  Text("Nodos", style: MyTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.surface,
                              border: Border.all(color: MyColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    measuringDays,
                                    style: MyTextStyles.metricValue,
                                  ),
                                  Text(
                                    "Midiendo",
                                    style: MyTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    buildRow(
                      label: "Editar mis datos",
                      radius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      onTap: profile == null
                          ? null
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfile(profile: profile!),
                                ),
                              );
                              loadData();
                            },
                      trailing: Icon(
                        Icons.chevron_right,
                        color: MyColors.secondaryText,
                      ),
                    ),

                    buildRow(
                      label: "Cambiar contraseña",
                      onTap: onResetPassword,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: MyColors.secondaryText,
                      ),
                    ),

                    buildRow(
                      label: "Conectar con el nodo",
                      radius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: MyColors.primarySoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "FASE 3",
                          style: MyTextStyles.chip.copyWith(
                            color: MyColors.primaryStrong,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 125),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLogout,
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            MyColors.background,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            MyColors.critical,
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: MyColors.criticalStrong,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          "Cerrar sesión",
                          style: MyTextStyles.button,
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