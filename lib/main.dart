import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_lamp/screens/dashboard.dart';
import 'utils.dart' as utils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  utils.preferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashBoard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
