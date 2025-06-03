import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserService.dart';
import 'package:theplantmobile/Services/FeedBackService.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  void _registerUser(BuildContext context) async{
    final response = await UserService().loginUser (
        username: "string",
        password: "string"
    );
  }

  void _sendFeedback(BuildContext context) async {
    final response = await FeedbackService().sendFeedback(
        userId: "A60647F6-C96A-45E4-B0B6-2641ED33CB8E",
        theme: "test",
        text: "str!",
        createdAt: "2025-06-03T00:18:49.683Z",
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA" // полный токен
    );

    if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Фидбек успешно отправлен')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Ошибка: ${response?.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _registerUser(context),
            child: const Text('Зарегистрироваться'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _sendFeedback(context),
            child: const Text("Отправить фидбек"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => UserService().getUserById(
                userId: "83ab154a-7192-4dd4-b77b-3bcd1088cb54",
                bearerToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6IjgzYWIxNTRhLTcxOTItNGRkNC1iNzdiLTNiY2QxMDg4Y2I1NCIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IlVzZXIiLCJleHAiOjE3ODA0NDQ4MTQsImlzcyI6Imh0dHBzOi8vbG9jYWxob3N0OjgwMDEiLCJhdWQiOiJodHRwczovL2xvY2FsaG9zdDo4MDAxIn0.SpaQtj-D3KLWJflNUPb1q3NZ0SwKRamCErC_mw99jUA"),
            child: const Text("get user"),
          ),
        ],
      ),
    );
  }
}