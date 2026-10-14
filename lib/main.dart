import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/home_screen.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await TokenStorage().read();

  runApp(CashPathApp(isLoggedIn: token != null));
}

class CashPathApp extends StatelessWidget {
  const CashPathApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
