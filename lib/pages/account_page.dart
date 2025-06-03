import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _ProfileState();
}

class _ProfileState extends State<AccountPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _signIn() async {
    await AuthService().signInWithGoogle();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _user != null
                  ? 'Вы вошли как: ${_user!.email}'
                  : 'Вы не вошли',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Регистрация / Вход'),
            ),
            const SizedBox(height: 10),
            if (_user != null)
              ElevatedButton(
                onPressed: _signOut,
                child: const Text('Выйти'),
              ),
          ],
        ),
      ),
    );
  }
}
