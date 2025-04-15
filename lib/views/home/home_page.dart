// views/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_booking/views/ressource_page.dart'; // Assure-toi que le fichier existe
import 'package:flutter_booking/views/calendar/reservation_page.dart'; // Page de réservation

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Ressources'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ResourcePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Réservations'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservationPage()), // Navigue vers la page de réservation
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Bienvenue sur la page d\'accueil!'),
      ),
    );
  }
}
