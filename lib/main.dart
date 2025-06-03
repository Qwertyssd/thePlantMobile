import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:theplantmobile/auth/auth.dart';
import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/home_page.dart';
import 'pages/garden_page.dart';
import 'pages/account_page.dart';
import 'pages/notification_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Navigation Example',
      home: HomeNavigator(),
    );
  }
}

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeTabPage(),
    GardenPage(),
    NotificationPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Garden'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Notification'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}