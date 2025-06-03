import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';

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

  /// Захардкожений токен (можна винести в налаштування)
  final _hardcodedToken = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImE2MDY0N2Y2LWM5NmEtNDVlNC1iMGI2LTI2NDFlZDMzY2I4ZSIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA1MjA1NTEsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.GlPjhr8sVcxSoOUJ5UfZkVWNXU4F383KdZjWoPx3fkM'; // ← встав свій повний токен

  /// Захардкожений userId (для тестування)
  final _hardcodedUserId = 'A60647F6-C96A-45E4-B0B6-2641ED33CB8E'; // ← встав потрібний userId

  Future<List<UserPlant>> getUserPlantsById() async {
    final url = Uri.parse('$_baseUrl/api/UserGarden/$_hardcodedUserId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': _hardcodedToken,
    };

    try {
      final ioClient = _createIOClient();
      final response = await ioClient.get(url, headers: headers);

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserPlant.fromJson(json)).toList();
      } else {
        throw Exception('Не вдалося отримати UserPlants');
      }
    } catch (e) {
      print('❗ Помилка при отриманні UserPlants: $e');
      rethrow;
    }
  }
}
