import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserService.dart';


class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  void _loginUser(BuildContext context) async{
    final response = await UserService().loginUser (
        username: "string",
        password: "string"
    );
  }

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Home'),
        ],
      ),
    );
  }
}