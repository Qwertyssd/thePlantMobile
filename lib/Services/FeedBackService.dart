import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:theplantmobile/global.dart';
class FeedbackService {
  final String _baseUrl = '${baseUrl}Feedbacks/'; // HTTPS, как в редиректе

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  Future<http.Response?> sendFeedback({
    required String userId,
    required String theme,
    required String text,
    required String createdAt,
    required String token,
  }) async {
    final url = Uri.parse(_baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "userId": userId,
      "theme": theme,
      "text": text,
      "createdAt": createdAt,
    });

    try {
      final client = createHttpClient();
      final response = await client.post(url, headers: headers, body: body);

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
