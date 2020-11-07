import 'package:flutter/material.dart';
import 'Pages/LoginPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lua Negra Chat App',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
