import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'global.dart';
import 'Services/UserService.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/garden_page.dart';
import 'pages/account_page.dart';

import 'pages/reminders_page.dart';
import 'pages/user_garden_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initAuth();
  runApp(const MyApp());
}

Future<void> initAuth() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('⛔ Нет авторизованного Firebase пользователя');
    return;
  }

  final username = user.email?.split('@')[0] ?? 'anonymous';
  final password = user.uid;

  final loginResponse = await UserService().loginUser(
    username: username,
    password: password,
  );

  if (loginResponse != null && loginResponse.statusCode == 200) {
    setJwtToken(loginResponse.body);
    print('✅ JWT токен установлен при запуске');
  } else {
    print('❗ Backend логин не удался — пробуем регистрацию');
    final registerResponse = await UserService().registerUser();

    if (registerResponse != null && registerResponse.statusCode == 200) {
      final loginAgain = await UserService().loginUser(
        username: username,
        password: password,
      );
      if (loginAgain != null && loginAgain.statusCode == 200) {
        setJwtToken(loginAgain.body);
        print('✅ JWT установлен после регистрации при запуске');
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomeNavigator();
        }
        return const SignInPage();
      },
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        print('❗ Пользователь не аутентифицирован');
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }

      final username = user.email?.split('@')[0] ?? 'anonymous';
      final password = user.uid;

      final loginResponse = await UserService().loginUser(username: username, password: password);

      if (loginResponse != null && loginResponse.statusCode == 200) {
        setJwtToken(loginResponse.body);
        print('✅ Успешный вход!');
      } else {
        final registerResponse = await UserService().registerUser();
        if (registerResponse != null && registerResponse.statusCode == 200) {
          final loginAgain = await UserService().loginUser(username: username, password: password);
          if (loginAgain != null && loginAgain.statusCode == 200) {
            setJwtToken(loginAgain.body);
            print('✅ Успешный вход после регистрации!');
          } else {
            print('❗ Не удалось войти после регистрации');
          }
        } else {
          print('❗ Регистрация не удалась');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка входу: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Війти через Google'),
          onPressed: _signInWithGoogle,
        ),
      ),
    );
  }
}

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}
final userPlantService = UserPlantService(baseUrl: 'https://10.0.2.2:8001');

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;




  static final List<Widget> _pages = <Widget>[
    HomeTabPage(),
    GardenPage(),
    UserGardenPage(userPlantService: userPlantService),
    RemindersPage(),
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
          NavigationDestination(icon: Icon(Icons.settings), label: 'UserGarden'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Notification'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
