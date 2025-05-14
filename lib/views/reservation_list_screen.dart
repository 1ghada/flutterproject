import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/reservation_service.dart';
import '/models/reservation.dart';

class ReservationListScreen extends StatefulWidget {  // Define the StatefulWidget
  @override
  _ReservationListScreenState createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen> {
  final _reservationService = ReservationService();
  List<Reservation> reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // Charger les réservations
  Future<void> _loadReservations() async {
    final result = await _reservationService.getAllReservations(); // Correction ici, sans userId
    setState(() {
      reservations = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: reservations.isEmpty
          ? Center(child: Text("Aucune réservation trouvée."))
          : ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return ListTile(
                  title: Text("Ressource ID: ${reservation.resourceId}"),
                  subtitle: Text(
                    "Date: ${reservation.date}\nCréneau: ${reservation.timeSlot}\nStatut: ${reservation.status}"
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () async {
                      await _reservationService.cancelReservation(reservation.id!);
                      _loadReservations();
                    },
                  ),
                );
              },
            ),
    );
  }
}
