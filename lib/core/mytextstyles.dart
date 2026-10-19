import 'package:flutter/material.dart';

import 'mycolors.dart';

class MyTextStyles {
  //----------- Fuentes ------------//

  static const String display = 'Fraunces'; // Fuentes titulos
  static const String normal = 'PlusJakartaSans'; // Fuentes de texto normal

  //----------- Titulos ------------//

  static const TextStyle screenTitle = TextStyle(
    fontFamily: display,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: MyColors.primaryText,
    letterSpacing: -0.4,
  ); // Título grande de la pantalla.

  static const TextStyle subtitle = TextStyle(
    fontFamily: display,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: MyColors.primaryText,
  ); // Título de sección sobre fondo claro

  static const TextStyle subtitleDark = TextStyle(
    fontFamily: display,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: MyColors.primaryTextOnDark,
  ); // Titulo de sección sobre fondo oscuro

  static const TextStyle zumBeeBrand = TextStyle(
    fontFamily: display,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: MyColors.primaryText,
  ); // La palabra "Zum-Bee"

  //----------- Cuerpo en fondo claro ------------//

  static const TextStyle body = TextStyle(
    fontFamily: normal,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: MyColors.bodyText,
    height: 1.6,
  ); // Párrafos y texto dentro de los campos

  static const TextStyle bodySmall = TextStyle(
    fontFamily: normal,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: MyColors.secondaryText,
  ); // Subtítulos, notas al pie, nombre bajo el medidor

  static const TextStyle label = TextStyle(
    fontFamily: normal,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: MyColors.secondaryText,
    letterSpacing: 0.5,
  ); // Mayúsculas sobre un campo o sección, y la unidad del medidor

  //----------- Cuerpo en fondo oscuro ------------//

  static const TextStyle bodyDark = TextStyle(
    fontFamily: normal,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: MyColors.primaryTextOnDark,
    height: 1.6,
  ); // Párrafo sobre la tarjeta café

  static const TextStyle bodySmallDark = TextStyle(
    fontFamily: normal,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: MyColors.secondaryTextOnDark,
  ); // Subtítulo sobre la tarjeta café

  //----------- Extras ------------//

  static const TextStyle button = TextStyle(
    fontFamily: normal,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  ); // Sin color: lo pone el botón con foregroundColor

  static const TextStyle link = TextStyle(
    fontFamily: normal,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: MyColors.primaryStrong,
    decoration: TextDecoration.underline,
    decorationColor: MyColors.primary,
  ); // "Regístrate", "Inicia sesión", todo tipo de enlace

  static const TextStyle chip = TextStyle(
    fontFamily: normal,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  ); // Sin color: lo pone el estado de conexión

  static const TextStyle metricValue = TextStyle(
    fontFamily: normal,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MyColors.primaryText,
  ); // El tipo de texto de los metric_gauge

  static const TextStyle alertTitle = TextStyle(
    fontFamily: normal,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  ); // Titulo sin color: lo pone la severidad (Verde, Azul, Naranja, Rojo)

  static const TextStyle alertBody = TextStyle(
    fontFamily: normal,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ); // Texto sin color: lo pone la severidad (Verde, Azul, Naranja, Rojo)

  static const TextStyle navLabel = TextStyle(
    fontFamily: normal,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}
