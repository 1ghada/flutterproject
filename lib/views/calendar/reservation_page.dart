// views/calendar/reservation_page.dart

import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _resourceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _error;

  // Méthode pour traiter la réservation (ajuster selon ton besoin)
  Future<void> _reserve() async {
    // Logique de réservation à ajouter ici

    // Exemple de traitement de réservation (mettre en place le modèle de réservation)
    try {
      final resource = _resourceController.text.trim();
      final date = _dateController.text.trim();
      final time = _timeController.text.trim();

      if (resource.isEmpty || date.isEmpty || time.isEmpty) {
        throw Exception('Tous les champs sont requis.');
      }

      // Ajoute la logique pour réserver ici, par exemple, enregistrer la réservation dans une base de données

      // Après la réservation, tu peux afficher un message de succès ou retourner à la page précédente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation effectuée avec succès')),
      );
      Navigator.pop(context); // Ferme la page de réservation et revient à la page précédente
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une ressource'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Veuillez remplir les informations pour réserver une ressource'),
            const SizedBox(height: 20),
            TextField(
              controller: _resourceController,
              decoration: const InputDecoration(
                labelText: 'Nom de la ressource',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date de réservation',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Horaire de réservation',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _reserve,
              child: const Text('Réserver'),
            ),
          ],
        ),
      ),
    );
  }
}
