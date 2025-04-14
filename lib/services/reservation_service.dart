import 'package:flutter_booking/models/reservation.dart';
import 'package:flutter_booking/db/database.dart';

class ReservationService {
  // Ajouter une réservation à la base de données
  Future<void> addReservation(int userId, int resourceId, String date, String timeSlot) async {
    final db = await AppDatabase.database;
    await db.insert('reservations', {
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'timeSlot': timeSlot,
    });
  }

  // Récupérer toutes les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations(int userId) async {
    final db = await AppDatabase.database;
    final reservationList = await db.query(
      'reservations',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    return reservationList
        .map((reservation) => Reservation.fromJson(reservation))
        .toList();
  }

  // Récupérer toutes les réservations d'une ressource
  Future<List<Reservation>> getResourceReservations(int resourceId) async {
    final db = await AppDatabase.database;
    final reservationList = await db.query(
      'reservations',
      where: 'resourceId = ?',
      whereArgs: [resourceId],
    );

    return reservationList
        .map((reservation) => Reservation.fromJson(reservation))
        .toList();
  }
}
