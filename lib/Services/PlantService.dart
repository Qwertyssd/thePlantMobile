import 'dart:convert';
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:theplantmobile/Models/PlantImage.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/Plant.dart';
import 'package:theplantmobile/Models/PlantCareInstruction.dart';

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

  Future<PlantCareInstruction> getPlantCareInstructions(String plantId, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}/$plantId/careinstructions');
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
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return PlantCareInstruction.fromJson(jsonMap);
      } else {
        throw Exception('Не вдалося завантажити інструкції по догляду');
      }
    } catch (e) {
      print('❗ Помилка при отриманні інструкцій: $e');
      rethrow;
    }
  }

  Future<Plant> getPlantById(String plantId, String bearerToken) async {
    final url = Uri.parse('$_baseUrl/$plantId');
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
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return Plant.fromJson(jsonMap);
      } else {
        throw Exception('Не вдалося завантажити дані рослини');
      }
    } catch (e) {
      print('❗ Помилка при отриманні даних рослини: $e');
      rethrow;
    }
  }

  Future<List<PlantImage>> getPlantImages(String plantId, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}Images/plant/$plantId');
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
        return data.map((json) => PlantImage.fromJson(json)).toList();
      } else {
        throw Exception('Не вдалося отримати фото рослини');
      }
    } catch (e) {
      print('❗ Помилка при отриманні фото рослини: $e');
      rethrow;
    }
  }

}
