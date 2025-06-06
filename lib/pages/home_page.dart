import 'package:flutter/material.dart';
import 'package:theplantmobile/Services/NotificationService.dart';



class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: ElevatedButton(
        onPressed: () async {
            await NotificationService().showNotification(
              title: '123',
              body: 'body',
            );
          },
          child: const Text("gigi gaga"),
        ),
      )
    );
  }
}