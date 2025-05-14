import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/reservation_service.dart';
import '/services/ressources_service.dart';
import '/models/resource.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _reservationService = ReservationService();
  final _resourceService = ResourceService();

  Resource? selectedResource;
  DateTime? selectedDate;

  List<Resource> resources = [];

  @override
  void initState() {
    super.initState();
    loadResources();
  }

  Future<void> loadResources() async {
    final result = await _resourceService.getAllResources();
    setState(() {
      resources = result;
    });
  }

  Future<int?> getUserIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> submitReservation() async {
    final userId = await getUserIdFromPreferences();

    if (selectedResource == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une ressource et une date.')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non identifié. Veuillez vous connecter.')),
      );
      return;
    }

    final dateStr = selectedDate!.toIso8601String().split("T").first;

    try {
      await _reservationService.reserve(
        userId: userId,
        resourceId: selectedResource!.id!,
        date: dateStr,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réservation réussie !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réserver une ressource"),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Resource>(
              hint: Text("Choisir une ressource"),
              value: selectedResource,
              items: resources.map((r) {
                return DropdownMenuItem(
                  value: r,
                  child: Text(r.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedResource = value;
                });
              },
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text(selectedDate == null
                  ? "Choisir une date"
                  : "${selectedDate!.toLocal()}".split(' ')[0]),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitReservation,
              child: Text("Réserver"),
            ),
          ],
        ),
      ),
    );
  }
}
