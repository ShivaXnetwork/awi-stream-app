import 'package:flutter/material.dart';

void main() {
  runApp(const AwiStreamApp());
}

class AwiStreamApp extends StatelessWidget {
  const AwiStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AwiStream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Crunchyroll jaisa dark background
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AwiStream', 
          style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Welcome to AwiStream!\nAnime Engine is Ready 🚀', 
          textAlign: TextAlign.center, 
          style: TextStyle(fontSize: 20)
        ),
      ),
    );
  }
}
