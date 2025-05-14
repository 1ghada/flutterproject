import 'package:flutter/material.dart';
import 'package:flutter_booking/views/ressource_page.dart';
import 'package:flutter_booking/views/calendar/reservation_page.dart';
import 'package:flutter_booking/views/reservation_list_screen.dart'; // ✅ Import ajouté

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
              title: const Text('Faire une réservation'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BookingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Mes Réservations'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationListScreen()),
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
