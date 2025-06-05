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
    final url = Uri.parse('${_baseUrl}/api/UserPlant/$_hardcodedUserId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_hardcodedToken != null) 'Authorization': _hardcodedToken!,
    };


    try {
      final ioClient = _createIOClient();
      final response = await ioClient.get(url, headers: headers);

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserPlant.fromJson(json)).toList();
      }
      if(response.statusCode == 400)
        {
          throw Exception('Не вдалося отримати UserPlants 41');
        }
      else {
        throw Exception('Не вдалося отримати UserPlants');
      }
    } catch (e) {
      print('❗ Помилка при отриманні UserPlants: $e');
      print('📥 URL: $url');
      print('📥 Headers: $headers');


      rethrow;
    }
  }
}
