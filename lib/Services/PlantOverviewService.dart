import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:theplantmobile/global.dart';
import 'package:theplantmobile/Models/PlantOverview.dart';

class PlantOverviewService {
  final _baseUrl = baseUrl;

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  }

  IOClient createHttpClient() {
    return IOClient(_createHttpClient());
  }

  /// Отримати PlantOverview за ID
  Future<PlantOverview> getPlantOverview(String overviewId, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}PlantOverview/$overviewId');
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
        final data = jsonDecode(response.body);
        return PlantOverview.fromJson(data);
      } else {
        throw Exception('Failed to load plant overview: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ Error fetching plant overview: $e');
      rethrow;
    }
  }

  /// Створити PlantOverview
  Future<bool> createPlantOverview(PlantOverview plantOverview, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}PlantOverview');
    final ioClient = createHttpClient();

    try {
      final body = jsonEncode(plantOverview.toJson());

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
        print('❗ Server error: ${response.statusCode}');
        print('❗ Response body: ${response.body}');
        throw Exception('Failed to create plant overview. Server responded with status code: ${response.statusCode}');
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

  /// Видалити PlantOverview
  Future<bool> deletePlantOverview(String overviewId, String bearerToken) async {
    final url = Uri.parse('${_baseUrl}PlantOverview/$overviewId');
    final ioClient = createHttpClient();

    try {
      final response = await ioClient.delete(
        url,
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 204) {
        return true;
      } else {
        print('❗ Server error: ${response.statusCode}');
        print('❗ Response body: ${response.body}');
        throw Exception('Failed to delete plant overview. Server responded with status code: ${response.statusCode}');
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
