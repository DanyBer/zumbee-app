import 'package:flutter/material.dart';
import 'package:zumbee_app/core/mycolors.dart';
import 'package:zumbee_app/core/mytextstyles.dart';
import 'package:zumbee_app/screens/login_screen.dart';
import 'package:zumbee_app/screens/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, right: 20, left: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_nature, size: 30),
                  Text("  Zum-Bee", style: MyTextStyles.zumBeeBrand),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "Tu colmena, vigilada sin abrirla",
                  style: MyTextStyles.screenTitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "Sensores dentro de la colmena que reportan a tu celular. Menos visitas, menos estres para las abejas.",
                  style: MyTextStyles.body,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: MyColors.surfaceDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 225,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
        
                      children: [
                        Text(
                          "QUÉ MEDIMOS",
                          style: MyTextStyles.bodyDark,
                          textAlign: TextAlign.left,
                        ),
        
                        Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: MyColors.primary,
                              size: 30,
                            ),
        
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Temperatura y humedad",
                                  style: MyTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "La cría necesita entre 34 y 36°C",
                                  style: MyTextStyles.bodySmallDark,
                                ),
                              ],
                            ),
                          ],
                        ),
        
                        Row(
                          children: [
                            Icon(
                              Icons.graphic_eq,
                              color: MyColors.primary,
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sonido de la colonia",
                                  style: MyTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "El zumbido es lo primero en avisar",
                                  style: MyTextStyles.bodySmallDark,
                                ),
                              ],
                            ),
                          ],
                        ),
        
                        Row(
                          children: [
                            Icon(Icons.scale, color: MyColors.primary, size: 25),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Peso de la colmena",
                                  style: MyTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  "Sube con el néctar, cae con el enjambre",
                                  style: MyTextStyles.bodySmallDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(MyColors.primary),
                      foregroundColor: WidgetStatePropertyAll(
                        MyColors.primaryText,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                      ),
                    ),
                    child: Text("Crear cuenta", style: MyTextStyles.button),
                  ),
                ),
              ),
        
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        MyColors.background,
                      ),
                      foregroundColor: WidgetStatePropertyAll(
                        MyColors.primaryText,
                      ),
        
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          side: BorderSide(color: MyColors.border, width: 1.5),
                        ),
                      ),
                    ),
                    child: Text("Ya tengo cuenta", style: MyTextStyles.button),
                  ),
                ),
              ),
            ], // Children
          ),
        ),
      ),
    );
  }
}
