import 'package:flutter/material.dart';
import '../api_client.dart';

class HomeScreen extends StatefulWidget {
  final ApiClient api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.api.me();
      setState(() {
        me = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await widget.api.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Logged out. Riavvia l\'app per loggarti.')))),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: [
        IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
      ]),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text('Ciao ${me?['name'] ?? 'utente'} (email: ${me?['email'] ?? '-'})'),
      ),
    );
  }
}
