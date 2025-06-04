// lib/Services/ReminderService.dart
import 'dart:convert';
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:theplantmobile/Models/Reminder.dart';

class ReminderService {
  final String baseUrl = "https://10.0.2.2:8001/api";

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  Future<List<Reminder>> getUserReminders(String userId, String bearerToken) async {
    final url = Uri.parse('$baseUrl/Reminders/user/$userId');
    final ioClient = createHttpClient();

    try {
      final response = await ioClient.get(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reminder.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reminders: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ Error fetching reminders: $e');
      rethrow;
    }
  }

  Future<bool> createReminder(Reminder reminder, String bearerToken) async {
    final url = Uri.parse('$baseUrl/Reminders');
    final ioClient = createHttpClient();

    final body = jsonEncode(reminder.toJson());

    final response = await ioClient.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return response.statusCode == 201 || response.statusCode == 200;
  }
}
