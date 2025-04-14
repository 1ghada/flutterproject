import 'package:flutter/material.dart';
import 'package:flutter_booking/db/database.dart'; // Si tu veux récupérer les données de la base
import 'package:flutter_booking/models/resource.dart'; // Assure-toi que cette classe existe

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Resource> resources = []; // Liste des ressources à réserver
  DateTime selectedDate = DateTime.now(); // Date sélectionnée
  String selectedTimeSlot = ""; // Plage horaire sélectionnée

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  // Charge les ressources depuis la base de données
  Future<void> _loadResources() async {
    final db = await AppDatabase.database;
    final resourceList = await db.query('resources');
    setState(() {
      resources = resourceList.map((resource) => Resource.fromJson(resource)).toList();
    });
  }

  // Gère la sélection d'une ressource
  Future<void> _reserveResource(Resource resource) async {
    // Ici, on suppose qu'un utilisateur est déjà authentifié
    final userId = 1; // À remplacer par l'ID de l'utilisateur connecté
    final reservationDate = selectedDate.toIso8601String();
    
    // Enregistrer la réservation dans la base de données
    final db = await AppDatabase.database;
    await db.insert('reservations', {
      'userId': userId,
      'resourceId': resource.id,
      'date': reservationDate,
      'timeSlot': selectedTimeSlot,
    });

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Réservation effectuée pour ${resource.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réservation de Ressources')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection de la date
            const Text(
              'Sélectionner une date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Text('Choisir une date: ${selectedDate.toLocal()}'),
            ),
            const SizedBox(height: 16),

            // Sélection de l'heure
            const Text(
              'Sélectionner une plage horaire',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedTimeSlot.isEmpty ? null : selectedTimeSlot,
              hint: const Text('Sélectionner une heure'),
              items: <String>['9:00 - 12:00', '13:00 - 16:00', '16:00 - 19:00']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTimeSlot = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Liste des ressources disponibles
            const Text(
              'Ressources disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: resources.length,
                itemBuilder: (context, index) {
                  final resource = resources[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(resource.name),
                      subtitle: Text('Type: ${resource.type}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (selectedTimeSlot.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez choisir une heure.')),
                            );
                          } else {
                            _reserveResource(resource);
                          }
                        },
                        child: const Text('Réserver'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
