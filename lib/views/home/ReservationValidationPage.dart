import 'package:flutter/material.dart';
import '/models/reservation.dart';
import '/services/reservation_service.dart';

class ReservationValidationPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ReservationValidationPageState createState() =>
      _ReservationValidationPageState();
}

class _ReservationValidationPageState extends State<ReservationValidationPage> {
  late Future<List<Reservation>> _pendingReservations;
  final ReservationService _reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _loadPendingReservations();
  }

  void _loadPendingReservations() {
    _pendingReservations = _reservationService.getPendingReservations();
  }

  void _validateReservation(int reservationId) async {
    await _reservationService.validateReservation(reservationId, 'validée');
    _loadPendingReservations(); // Recharger les réservations après validation
  }

  void _rejectReservation(int reservationId) async {
    await _reservationService.validateReservation(reservationId, 'rejetée');
    _loadPendingReservations(); // Recharger les réservations après rejet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validation des réservations'),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _pendingReservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune réservation en attente'));
          }

          final reservations = snapshot.data!;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Ressource: ${reservation.resourceId}'),
                  subtitle: Text('Date: ${reservation.date}, Créneau: ${reservation.timeSlot}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _validateReservation(reservation.id!),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectReservation(reservation.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
