import 'package:flutter/material.dart';
import 'views/ressource_page.dart'; // Assure-toi que ce fichier existe bien

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ResourcePage(), // 👈 On affiche directement la page des ressources
      debugShowCheckedModeBanner: false,
    );
  }
}
