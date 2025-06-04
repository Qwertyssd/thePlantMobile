import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/UserService.dart';
import 'package:theplantmobile/Services/FeedBackService.dart';

class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  void _loginUser(BuildContext context) async{
    final response = await UserService().loginUser (
        username: "string",
        password: "string"
    );
  }


  @override
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