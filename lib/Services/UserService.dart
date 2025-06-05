import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:theplantmobile/global.dart';

class UserService {
  final String _baseUrl = "https://10.0.2.2:8001/api/User";

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  Future<http.Response?> loginUser({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
    };

    final body = jsonEncode({
      "username": username,
      "password": password,
    });

    try {
      final ioClient = IOClient(_createHttpClient());
      final response = await ioClient.post(url, headers: headers, body: body);
      print('Body: ${response.body}');
      setJwtToken(response.body);
      return response;
    } catch (e) {
      print('Ошибка при логине: $e');
      return null;
    }
  }

  Future<http.Response?> getUserById({
    required String userId,
    required String bearerToken,
  }) async {

    final url = Uri.parse('https://10.0.2.2:8001/api/User/$userId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };

    try {
      final client = createHttpClient();
      final response = await client.get(url, headers: headers);
      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      return response;
    } catch (e) {
      print('❗ Ошибка при получении пользователя: $e');
      return null;
    }
  }

  Future<http.Response?> registerUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('Пользователь не аутентифицирован');
      return null;
    }

    final username = user.email?.split('@').first ?? 'anonymous';
    final email = user.email!;
    final firebaseUid = user.uid;

    final body = jsonEncode({
      "username": username,
      "email": email,
      "timeZone": "UTC",
      "location": "Unknown",
      "lang": 0,
      "isAdmin": false,
      "password": firebaseUid,
      "allowsNotifications": true,
      "feedbacks": [],
      "userSubscriptions": [],
      "userAchievements": [],
      "userPlants": [],
      "reminders": []
    });

    final headers = {
      'Content-Type': 'application/json',
      'accept': 'text/plain',
    };

    try {
      final url = Uri.parse('$_baseUrl/register');
      final client = createHttpClient();
      final response = await client.post(url, headers: headers, body: body); // <-- вот тут исправлено на POST

      print('Статус: ${response.statusCode}');
      print('Ответ: ${response.body}');

      return response;
    } catch (e) {
      print('Ошибка регистрации: $e');
      return null;
    }
  }
}
