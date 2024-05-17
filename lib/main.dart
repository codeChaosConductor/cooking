import 'package:flutter/material.dart';

import 'package:cooking/home.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,
            brightness: Brightness.dark,
            accentColor: Colors.deepOrange.shade100),
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
