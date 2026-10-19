import 'dart:ui';

class MyColors {

//--------------- BackGround ---------------//

  static const Color primary = Color(0xFFF5A623); 
  static const Color primaryStrong = Color(0xFFB87A06); 
  static const Color primarySoft = Color(0xFFFDF3E0); 
 
  static const Color background = Color(0xFFFAEED9); // Fondo crema de la app
  static const Color surface = Color(0xFFFFFFFF); // Tarjetas blancas y campos
  static const Color surfaceDark = Color(0xFF3B2A20); // Tarjeta café del apiario
  static const Color border = Color(0xFFEFE9E0); // Borde de tarjetas y campos

//--------------- Text ---------------//

  static const Color primaryText = Color(0xFF1F1A16); // Títulos y texto fuerte
  static const Color bodyText = Color(0xFF453D35); // Párrafos
  static const Color secondaryText = Color(0xFF8C857C); // Subtítulos, etiquetas, iconos grises
  static const Color primaryTextOnDark = Color(0xFFFBF8F4); // Texto sobre colores oscuros
  static const Color secondaryTextOnDark = Color(0xFFC4B5A4); // Subtítulo sobre colores oscuros

//--------------- Estados ---------------//
//----------- Bien y Humedad ------------//

  static const Color healthy = Color(0xFF2E8B70); // Anillo de humedad, puntos verdes
  static const Color healthyStrong = Color(0xFF1F6B55); // Letra verde
  static const Color healthySoft = Color(0xFFE9F3EF); // Fondo de alerta positiva

//---------- Calor y Peligro ------------//
  
  static const Color critical = Color(0xFFC93F3F); // Iconos y marcadores
  static const Color criticalStrong = Color(0xFFA8302F); // Letra roja
  static const Color criticalSoft = Color(0xFFFCECEC); // Fondo del botón Calentar y de la alerta grave

//------------ Frio y Temp -------------//

  static const Color cold = Color(0xFF2E7D8F); // Anillo de temperatura
  static const Color coldStrong = Color(0xFF1C5C6B); // Letra e icono de Enfriar
  static const Color coldSoft = Color(0xFFE6F0F3); // Fondo del botón Enfriar

}
