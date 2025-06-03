import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';

import 'package:theplantmobile/Models/Plant.dart';  // Імпорт моделі, припустимо, що в окремому файлі plant.dart

class PlantService {
  final String _baseUrl = 'https://10.0.2.2:8001/api/Plant';

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  Future<List<Plant>> getPlants(String bearerToken) async {
    final url = Uri.parse(_baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };

    try {
      final ioClient = createHttpClient();
      final response = await ioClient.get(url, headers: headers);
      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Plant.fromJson(json)).toList();
      } else {
        throw Exception('Не удалось загрузить растения');
      }
    } catch (e) {
      print('❗ Ошибка при получении растений: $e');
      rethrow;
    }
  }
}
