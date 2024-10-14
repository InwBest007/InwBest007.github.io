import 'package:flutter/material.dart';
import 'package:myapp_recipe/Screen/login.dart';
import 'package:myapp_recipe/Screen/mainscreen.dart';
import 'package:myapp_recipe/Screen/account_screen.dart'; // หน้าบัญชีผู้ใช้

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Recipe Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => MainScreen(),
        '/account': (context) => AccountScreen(userName: 'User'),
      },
    );
  }
}
