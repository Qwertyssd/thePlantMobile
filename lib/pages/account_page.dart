import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Services/UserService.dart';
import '../auth/auth.dart';
import '../global.dart';
import '../Services/FeedbackService.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _ProfileState();
}

class _ProfileState extends State<AccountPage> {
  User? _user;

  void _showFeedbackDialog(BuildContext contextMounted) {
    String theme = '';
    String text = '';

    showDialog(
      context: contextMounted,
      builder: (context) {
        return AlertDialog(
          title: const Text('Залишити відгук'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Тема'),
                onChanged: (value) => theme = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Повідомлення'),
                maxLines: 4,
                onChanged: (value) => text = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                final userId = globalUserId ?? '';
                final token = globalJwtToken ?? '';
                final createdAt = DateTime.now().toIso8601String();

                final response = await FeedbackService().sendFeedback(
                  userId: userId,
                  theme: theme,
                  text: text,
                  createdAt: createdAt,
                  token: token,
                );

                final message = (response != null && response.statusCode == 200)
                    ? '✅ Відгук надіслано'
                    : '❗ Помилка надсилання';

                // Используем contextMounted — внешний контекст
                ScaffoldMessenger.of(contextMounted).showSnackBar(SnackBar(content: Text(message)));
              },
              child: const Text('Надіслати'),
            ),
          ],
        );
      },
    );
  }


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

    final loginResponse = await UserService().loginUser(
        username: username, password: password);
    if (loginResponse != null && loginResponse.statusCode == 200) {
      setJwtToken(loginResponse.body);
    } else {
      final registerResponse = await UserService().registerUser();
      if (registerResponse != null && registerResponse.statusCode == 200) {
        final loginAgain = await UserService().loginUser(
            username: username, password: password);
        if (loginAgain != null && loginAgain.statusCode == 200) {
          setJwtToken(loginAgain.body);
        }
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }




  Widget build(BuildContext context) {
    final userName = _user?.displayName ?? _user?.email?.split('@')[0] ??
        'Користувач';
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
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  backgroundColor: Colors.white24,
                  child: photoUrl == null ? const Icon(
                      Icons.person, size: 40, color: Colors.white) : null,
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftAlignedTextButton(
                        Icons.switch_account, 'Змінити аккаунт', _switchAcc),
                    _buildLeftAlignedTextButton(
                        Icons.lock, 'Принт JWT і User ID', () {
                      print('🔐 JWT: $globalJwtToken');
                      print('👤 User ID: $globalUserId');
                    }),
                    if (_user != null)
                      _buildLeftAlignedTextButton(
                          Icons.logout, 'Вийти', _signOut),
                    _buildLeftAlignedTextButton(
                        Icons.settings, 'Настройки (заглушка)',  (){
                    }),
                    _buildLeftAlignedTextButton(
                        Icons.info, 'О приложении (заглушка)', () {}),
                    _buildLeftAlignedTextButton(Icons.feedback, 'Залишити відгук', () => _showFeedbackDialog(context))

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
  Widget _buildLeftAlignedTextButton(IconData icon, String text,
      VoidCallback onPressed) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: Colors.black87,
        textStyle: const TextStyle(fontSize: 18),
      ),
      icon: Icon(icon, color: Colors.black54),
      label: Text(text),
      onPressed: onPressed,
    );
  }
}

