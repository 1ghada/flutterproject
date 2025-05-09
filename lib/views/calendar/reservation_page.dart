import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Ajout de l'importation
import '/services/reservation_service.dart';
import '/services/ressources_service.dart';
import '/models/resource.dart';

class BookingScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _reservationService = ReservationService();
  final _resourceService = ResourceService();

  Resource? selectedResource;
  DateTime? selectedDate;
  String? selectedTimeSlot;

  List<Resource> resources = [];
  List<String> availableTimeSlots = [];

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

  Future<void> checkAvailability() async {
    if (selectedResource != null && selectedDate != null) {
      final dateStr = selectedDate!.toIso8601String().split("T").first;
      final slots = await _reservationService.getAvailableTimeSlots(selectedResource!.id!, dateStr);
      setState(() {
        availableTimeSlots = slots;
        selectedTimeSlot = null;
      });
    }
  }

  // Récupérer l'ID de l'utilisateur à partir de SharedPreferences
  Future<int?> getUserIdFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> submitReservation() async {
    final userId = await getUserIdFromPreferences();
    
    if (userId != null && selectedResource != null && selectedDate != null && selectedTimeSlot != null) {
      final dateStr = selectedDate!.toIso8601String().split("T").first;

      await _reservationService.reserve(
        userId: userId,
        resourceId: selectedResource!.id!,
        date: dateStr,
        timeSlot: selectedTimeSlot!,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Réservation réussie !')));
    } else {
      // Si l'utilisateur n'est pas connecté ou des informations sont manquantes
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez vous connecter et compléter tous les champs.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Réserver une ressource")),
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
                  await checkAvailability();
                }
              },
            ),
            SizedBox(height: 10),
            if (availableTimeSlots.isNotEmpty)
              DropdownButton<String>(
                hint: Text("Choisir un créneau"),
                value: selectedTimeSlot,
                items: availableTimeSlots.map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTimeSlot = value;
                  });
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
