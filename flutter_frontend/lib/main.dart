import 'package:flutter/material.dart';
import 'package:flutter_backend/screens/login_screen.dart';
import 'services/token_store.dart';
import 'api_client.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TokenStore _store;
  late final ApiClient _api;
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _store = TokenStore();
    _api = ApiClient(_store);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = await _store.readToken();
    if (token != null) {
      try {
        await _api.me();
        _loggedIn = true;
      } catch (_) {
        _loggedIn = false;
        await _store.clear();
      }
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    return MaterialApp(
      title: 'MatchUp Auth',
      theme: ThemeData(useMaterial3: true),
      home: _loggedIn ? HomeScreen(api: _api) : LoginPage(api: _api),
    );
  }
}
