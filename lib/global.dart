import 'dart:convert';

String? globalJwtToken;
String? globalUserId;
String? baseUrl;

void setJwtToken(String jwt) {
  print('setJwtToken получил JWT: $jwt');
  globalJwtToken = jwt;
  baseUrl = 'https://10.0.2.2:8001/api/';
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) {
      print('Неверный формат JWT');
      return;
    }

    final payloadBase64 = base64.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(payloadBase64));
    final Map<String, dynamic> payload = json.decode(payloadString);

    globalUserId = payload["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"];
    print("userId из JWT: $globalUserId");
  } catch (e) {
    print('Ошибка при разборе JWT: $e');
  }
}
