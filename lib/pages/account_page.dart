import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Services/UserService.dart';
import '../auth/auth.dart';
import '../global.dart';

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

  Future<void> _switchAcc() async {
    await AuthService().switchAccount();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final username = user.email?.split('@')[0] ?? 'anonymous';
    final password = user.uid;

    final loginResponse = await UserService().loginUser(username: username, password: password);
    if (loginResponse != null && loginResponse.statusCode == 200) {
      setJwtToken(loginResponse.body);
    } else {
      final registerResponse = await UserService().registerUser();
      if (registerResponse != null && registerResponse.statusCode == 200) {
        final loginAgain = await UserService().loginUser(username: username, password: password);
        if (loginAgain != null && loginAgain.statusCode == 200) {
          setJwtToken(loginAgain.body);
        }
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _user?.displayName ?? _user?.email?.split('@')[0] ?? 'Користувач';
    final photoUrl = _user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Верхний блок с аватаркой
          Container(
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(width: 20),
                Text(
                  userName,
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Контейнер с кнопками
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftAlignedTextButton('Змінити аккаунт', _switchAcc),
                    _buildLeftAlignedTextButton('Принт JWT і User ID', () {
                      print('🔐 JWT: $globalJwtToken');
                      print('👤 User ID: $globalUserId');
                    }),
                    if (_user != null) _buildLeftAlignedTextButton('Вийти', _signOut),
                    _buildLeftAlignedTextButton('Настройки (заглушка)', () {}),
                    _buildLeftAlignedTextButton('О приложении (заглушка)', () {}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Кнопка без рамки с крупным текстом, выровнена влево
  Widget _buildLeftAlignedTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: Colors.black87,
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
