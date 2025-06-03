import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class UserService {
  final String _baseUrl = 'https://10.0.2.2:8001/api/User';

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
      print('Status code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
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
    //final url = Uri.parse('http://10.0.2.2:8000/api/User/$userId');
    final url = Uri.parse('https://10.0.2.2:8001/api/User/$userId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken',
    };

    try {
      final client = createHttpClient();
      //final client = http.Client();
      final response = await client.get(url, headers: headers);
      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      return response;
    } catch (e) {
      print('❗ Ошибка при получении пользователя: $e');
      return null;
    }
  }

}
