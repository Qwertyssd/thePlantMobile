import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:theplantmobile/Services/PlantService.dart';
import 'package:theplantmobile/Services/UserPlantsService.dart';
import 'global.dart';
import 'Services/UserService.dart';
import 'firebase_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pages/garden_page.dart';
import 'pages/account_page.dart';
import 'package:flutter/services.dart';
import 'pages/reminders_page.dart';
import 'pages/user_garden_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.green,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.green,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.green[300],
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const AuthGate(),
      navigatorObservers: [routeObserver],
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _loggedIn = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.green, // status bar color
        statusBarIconBrightness: Brightness.light, // status bar icon color
        systemNavigationBarColor: Colors.green, // navigation bar color
        systemNavigationBarIconBrightness: Brightness.light, // navigation bar icon color
      ),
    );
  }

  Future<void> _checkAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        try {
          await _handleBackendLogin(user);
          setState(() {
            _user = user;
            _loggedIn = true;
            _loading = false;
          });
        } catch (e) {
          print('Ошибка логина: $e');
          setState(() {
            _user = null;
            _loggedIn = false;
            _loading = false;
          });
        }
      } else {
        setState(() {
          _user = null;
          _loggedIn = false;
          _loading = false;
        });
      }
    });
  }

  Future<void> _handleBackendLogin(User user) async {
    final username = user.email?.split('@')[0] ?? 'anonymous';
    final password = user.uid;

    final loginResponse = await UserService().loginUser(
      username: username,
      password: password,
    );

    if (loginResponse != null && loginResponse.statusCode == 200) {
      setJwtToken(loginResponse.body);
    } else {
      final registerResponse = await UserService().registerUser();
      if (registerResponse != null && registerResponse.statusCode == 200) {
        final loginAgain = await UserService().loginUser(
          username: username,
          password: password,
        );
        if (loginAgain != null && loginAgain.statusCode == 200) {
          setJwtToken(loginAgain.body);
        } else {
          throw Exception('Ошибка авторизации после регистрации');
        }
      } else {
        throw Exception('Регистрация не удалась');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loggedIn && _user != null) {
      return const HomeNavigator();
    } else {
      return const SignInPage();
    }
  }
}

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
final userPlantService = UserPlantService(baseUrl: baseUrl!);
final plantService = PlantService();

class _HomeNavigatorState extends State<HomeNavigator> {
  int _selectedIndex = 0;




  static final List<Widget> _pages = <Widget>[

    GardenPage(),
    UserGardenPage(userPlantService: userPlantService, plantService: plantService,),
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

          NavigationDestination(icon: Icon(FontAwesomeIcons.leaf,  size: 24), label: 'UserGarden'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Notification'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
