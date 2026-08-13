import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  // ProviderScope পুরো app-কে wrap করে — এর নিচে যেকোনো widget থেকে
  // যেকোনো provider access করা যাবে।
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Architecture Boilerplate',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const LoginPage(),
    );
  }
}
