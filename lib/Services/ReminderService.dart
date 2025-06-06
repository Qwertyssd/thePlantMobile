// lib/Services/ReminderService.dart
import 'dart:convert';
import 'package:theplantmobile/global.dart';
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:theplantmobile/Models/Reminder.dart';


class ReminderService {

final _baseUrl = baseUrl;
  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  Future<List<Reminder>> getUserReminders(String userId, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}Reminders/user/$userId');
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

Future<List<Reminder>> getUserPlantReminders(String userPlantId, String bearerToken) async {
  final url = Uri.parse('${_baseUrl}Reminders/userplant/$userPlantId');
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
  final url = Uri.parse('${_baseUrl}Reminders');
  final ioClient = createHttpClient();

  try {
    final body = jsonEncode(reminder.toJson());

    final response = await ioClient.post(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📤 Request body: $body');
    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');


    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      // Якщо сервер відповів помилкою (наприклад 400 або 500)
      print('❗ Server error: ${response.statusCode}');
      print('❗ Response body: ${response.body}');
      throw Exception('Failed to create reminder. Server responded with status code: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('❗ Network error: $e');
    throw Exception('Network error: ${e.message}');
  } on FormatException catch (e) {
    print('❗ Invalid response format: $e');
    throw Exception('Invalid response format: ${e.message}');
  } catch (e) {
    print('❗ Unexpected error: $e');
    throw Exception('Unexpected error: $e');
  }
}

Future<bool> updateReminderStatus(Reminder reminder, int newStatus, String bearerToken) async {
  final url = Uri.parse('${_baseUrl}Reminders');
  final ioClient = createHttpClient();

  try {
    // Обчислюємо нову дату нагадування
    final newDateOfReminder = reminder.dateOfReminder.add(
      Duration(days: int.tryParse(reminder.frequency ?? '0') ?? 0),
    );


    final updatedReminder = Reminder(
      reminderId: reminder.reminderId,
      userPlantId: reminder.userPlantId,
      dateOfReminder: newDateOfReminder,
      reminderType: reminder.reminderType,
      frequency: reminder.frequency,
      status: newStatus, // Overdue
      completionType: reminder.completionType,
      previousDate: DateTime.now(),
      userPlant: reminder.userPlant,
    );
    print("Updated REM : ${updatedReminder.dateOfReminder}");
    final body = jsonEncode(updatedReminder.toJsonUpdate());
    print("Date ${int.tryParse(reminder.frequency!)}");

    final response = await ioClient.put(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('📤 PATCH body: $body');
    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode==204) {
      return true;
    } else {
      print('❗ Server error: ${response.statusCode}');
      print('❗ Response body: ${response.body}');
      throw Exception('Failed to update reminder status. Server responded with status code: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('❗ Network error: $e');
    throw Exception('Network error: ${e.message}');
  } on FormatException catch (e) {
    print('❗ Invalid response format: $e');
    throw Exception('Invalid response format: ${e.message}');
  } catch (e) {
    print('❗ Unexpected error: $e');
    throw Exception('Unexpected error: $e');
  }
}

Future<bool> checkAndUpdateReminderStatus(Reminder reminder, String bearerToken) async {
  final now = DateTime.now();
  final d = Duration(minutes: 5);
  final future = now.add(d);
  final ioClient = createHttpClient();
  final url = Uri.parse('${_baseUrl}Reminders');

  try {
    if (reminder.dateOfReminder.isBefore(future)) {
      if (reminder.status != 2) {



        final updatedReminder = Reminder(
          reminderId: reminder.reminderId,
          userPlantId: reminder.userPlantId,
          dateOfReminder: reminder.dateOfReminder,
          reminderType: reminder.reminderType,
          frequency: reminder.frequency,
          status: 2, // Overdue
          completionType: reminder.completionType,
          previousDate: reminder.previousDate,
          userPlant: reminder.userPlant,
        );
        print("Updated REM : ${updatedReminder.dateOfReminder}");
        final body = jsonEncode(updatedReminder.toJsonUpdate());

        final response = await ioClient.put(
          url,
          headers: {
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        print('📤 CheckAndUpdate request body: $body');
        print('📥 Status code: ${response.statusCode}');
        print('📥 Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 204) {
          print('✅ Статус нагадування оновлено на Overdue');
          return true;
        } else {
          print('❗ Server error: ${response.statusCode}');
          print('❗ Response body: ${response.body}');
          throw Exception(
              'Failed to update reminder. Server responded with status code: ${response.statusCode}');
        }
      } else {
        print('ℹ️ Статус нагадування вже Overdue');
        return false;
      }
    } else {
      print('✅ Нагадування актуальне, оновлення не потрібне');
      return false;
    }
  } on SocketException catch (e) {
    print('❗ Network error: $e');
    throw Exception('Network error: ${e.message}');
  } on FormatException catch (e) {
    print('❗ Invalid response format: $e');
    throw Exception('Invalid response format: ${e.message}');
  } catch (e) {
    print('❗ Unexpected error: $e');
    throw Exception('Unexpected error: $e');
  }

}

Future<bool> deleteReminder(String reminderId, String bearerToken) async {
  final url = Uri.parse('${_baseUrl}Reminders/$reminderId');
  final ioClient = createHttpClient();

  try {
    final response = await ioClient.delete(
      url,
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    print('📤 DELETE request to $url');
    print('📥 Status code: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print('❗ Server error: ${response.statusCode}');
      print('❗ Response body: ${response.body}');
      throw Exception('Failed to delete reminder. Server responded with status code: ${response.statusCode}');
    }
  } on SocketException catch (e) {
    print('❗ Network error: $e');
    throw Exception('Network error: ${e.message}');
  } on FormatException catch (e) {
    print('❗ Invalid response format: $e');
    throw Exception('Invalid response format: ${e.message}');
  } catch (e) {
    print('❗ Unexpected error: $e');
    throw Exception('Unexpected error: $e');
  }
}




}
