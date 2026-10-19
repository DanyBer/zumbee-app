import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingSpeakService {
  final String channelId;

  ThingSpeakService(this.channelId);

  Future<List<Map<String, dynamic>>> getHistory({int results = 20}) async {
    final url =
        'https://api.thingspeak.com/channels/$channelId/feeds.json?results=$results';

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('ThingSpeak respondió ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> feeds = data['feeds'];

    final List<Map<String, dynamic>> readings = [];
    for (final feed in feeds) {
      readings.add({
        'date': DateTime.parse(feed['created_at']).toLocal(),
        'temperature': toNumber(feed['field1']),
        'humidity': toNumber(feed['field2']),
        'weight': toNumber(feed['field3']),
        'frequency': toNumber(feed['field4']),
        'amplitude': toNumber(feed['field5']),
      });
    }

    return readings;
  }

  double toNumber(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}