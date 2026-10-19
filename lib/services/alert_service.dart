class AlertService {
  static const double minTemperature = 32;
  static const double maxTemperature = 36;
  static const double minHumidity = 50;
  static const double maxHumidity = 70;
  static const double maxWeightDrop = 0.15;
  static const int maxHoursWithoutData = 1;

  List<Map<String, dynamic>> analyze(List<Map<String, dynamic>> readings) {
    final List<Map<String, dynamic>> alerts = [];
    if (readings.isEmpty) return alerts;

    final last = readings.last;
    final DateTime lastDate = last['date'];
    final double temperature = last['temperature'];
    final double humidity = last['humidity'];
    final double weight = last['weight'];

    final int hoursWithoutData = DateTime.now().difference(lastDate).inHours;
    if (hoursWithoutData >= maxHoursWithoutData) {
      alerts.add({
        'severity': 'warning',
        'title': "Nodo sin reportar",
        'body':
            "La última lectura llegó hace $hoursWithoutData h. Revisa la alimentación del nodo o la cobertura LoRa.",
        'date': lastDate,
      });
    }

    if (temperature < minTemperature) {
      alerts.add({
        'severity': 'critical',
        'title': "Temperatura baja en la cría",
        'body':
            "${temperature.toStringAsFixed(1)} °C, por debajo del mínimo de ${minTemperature.toStringAsFixed(0)} °C. La cría puede enfriarse.",
        'date': lastDate,
      });
    } else if (temperature > maxTemperature) {
      alerts.add({
        'severity': 'critical',
        'title': "Temperatura alta en la cría",
        'body':
            "${temperature.toStringAsFixed(1)} °C, por encima del máximo de ${maxTemperature.toStringAsFixed(0)} °C. Riesgo de estrés térmico.",
        'date': lastDate,
      });
    }

    if (humidity < minHumidity) {
      alerts.add({
        'severity': 'warning',
        'title': "Humedad baja",
        'body':
            "${humidity.toStringAsFixed(0)} % HR, por debajo del ${minHumidity.toStringAsFixed(0)} % recomendado. Puede afectar la incubación.",
        'date': lastDate,
      });
    } else if (humidity > maxHumidity) {
      alerts.add({
        'severity': 'warning',
        'title': "Humedad alta",
        'body':
            "${humidity.toStringAsFixed(0)} % HR, por encima del ${maxHumidity.toStringAsFixed(0)} % recomendado. Favorece hongos en los cuadros.",
        'date': lastDate,
      });
    }

    if (readings.length >= 2) {
      final double previous = readings[readings.length - 2]['weight'];
      if (previous > 0) {
        final double drop = (previous - weight) / previous;
        if (drop > maxWeightDrop) {
          alerts.add({
            'severity': 'critical',
            'title': "Caída brusca de peso",
            'body':
                "El peso bajó ${(drop * 100).toStringAsFixed(0)} % entre lecturas, de ${previous.toStringAsFixed(2)} kg a ${weight.toStringAsFixed(2)} kg. Posible enjambrazón o cosecha no registrada.",
            'date': lastDate,
          });
        }
      }
    }

    return alerts;
  }
}
