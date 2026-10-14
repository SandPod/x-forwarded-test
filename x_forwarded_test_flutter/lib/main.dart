import 'package:flutter/material.dart';

import 'client.dart';
import 'screens/echo_screen.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'X-Forwarded-For Check',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const EchoScreen(),
    );
  }
}
