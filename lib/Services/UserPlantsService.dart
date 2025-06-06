import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:theplantmobile/global.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:theplantmobile/Models/UserPlant.dart';

class UserPlantService {
  final String _baseUrl;

  UserPlantService({required String baseUrl}) : _baseUrl = baseUrl;

  // HttpClient, який ігнорує помилки SSL-сертифікатів (для локальної розробки)
  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient _createIOClient() {
    return IOClient(_createHttpClient());
  }


  final _hardcodedToken = globalJwtToken;

  final _hardcodedUserId = globalUserId;

  Future<List<UserPlant>> getUserPlantsById() async {
    final url = Uri.parse('${_baseUrl}UserPlant/$_hardcodedUserId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_hardcodedToken != null) 'Authorization': _hardcodedToken!,
    };

    print('🔍 Починаємо запит на отримання UserPlants');
    print('📥 URL: $url');
    print('📥 Заголовки: $headers');
    print('🆔 Використовується userId: $_hardcodedUserId');
    print('🔑 Використовується токен: $_hardcodedToken');

    try {
      final ioClient = _createIOClient();
      print('⚙️ Клієнт створений, виконуємо GET запит...');
      final response = await ioClient.get(url, headers: headers);

      print('📥 Статус код відповіді: ${response.statusCode}');
      print('📥 Тіло відповіді: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ Дані успішно отримані, кількість записів: ${data.length}');
        return data.map((json) => UserPlant.fromJson(json)).toList();
      }
      else if (response.statusCode == 400) {
        print('❌ Помилка 400: Некоректний запит');
        throw Exception('Не вдалося отримати UserPlants — помилка 400');
      }
      else {
        print('❌ Помилка сервера: статус код ${response.statusCode}');
        throw Exception(' ${response.statusCode} Не вдалося отримати UserPlants. baseUrl: $baseUrl, userId: $globalUserId, токен: $globalJwtToken');
      }
    } catch (e, stacktrace) {
      print('❗ Виняток при отриманні UserPlants: $e');
      print('📥 URL запиту: $url');
      print('📥 Заголовки запиту: $headers');
      print('📋 Стек трейсу помилки: $stacktrace');
      rethrow;
    }
  }

  Future<bool> deleteUserPlant(String userPlantId) async {
    final url = Uri.parse('${_baseUrl}UserPlant/$userPlantId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_hardcodedToken != null) 'Authorization': _hardcodedToken!,
    };

    try {
      final ioClient = _createIOClient();
      final response = await ioClient.delete(url, headers: headers);

      print('📤 Delete Status code: ${response.statusCode}');
      print('📤 Delete Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❗ Помилка при видаленні UserPlant: $e');
      rethrow;
    }
  }

  Future<bool> addUserPlant(UserPlant userPlant) async {
    final url = Uri.parse('${_baseUrl}UserPlant');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_hardcodedToken != null) 'Authorization': _hardcodedToken!,
    };

    final body = jsonEncode(userPlant.toJson());

    try {
      final ioClient = _createIOClient();
      final response = await ioClient.post(url, headers: headers, body: body);

      print('📤 Status code: ${response.statusCode}');
      print('📤 Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('❗ Помилка при додаванні UserPlant: $e');
      rethrow;
    }
  }

  Future<bool> updateUserPlant(UserPlant userPlant) async {
    final url = Uri.parse('${_baseUrl}UserPlant');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_hardcodedToken != null) 'Authorization': _hardcodedToken!,
    };

    final body = jsonEncode(userPlant.toJson());

    try {
      final ioClient = _createIOClient();
      final response = await ioClient.put(
        url,
        headers: {
          'Authorization': 'Bearer $globalJwtToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('📤 PATCH Status code: ${response.statusCode}');
      print('📤 PATCH Response body: ${response.body}');

      return response.statusCode == 200;
    } catch (e, stacktrace) {
      print('❗ Помилка при оновленні UserPlant: $e');
      print('📥 URL запиту: $url');
      print('📥 Заголовки запиту: $headers');
      print('📋 Стек трейсу помилки: $stacktrace');
      rethrow;
    }
  }


}
