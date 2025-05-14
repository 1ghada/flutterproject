import 'package:flutter_booking/db/database.dart';
import 'package:flutter_booking/models/reservation.dart';

class ReservationService {
  // Vérifier la disponibilité d'une ressource pour une date donnée
  Future<bool> isResourceAvailable(int resourceId, String date) async {
    final db = await AppDatabase.database;

    // Vérifier si la ressource est déjà réservée à cette date
    final reserved = await db.query(
      'reservations',
      where: 'resourceId = ? AND date = ?',
      whereArgs: [resourceId, date],
    );

    return reserved.isEmpty;  // La ressource est disponible si aucune réservation n'existe
  }

  // Effectuer une réservation
  Future<void> reserve({
    required int userId,
    required int resourceId,
    required String date,
  }) async {
    final db = await AppDatabase.database;

    // Vérifier si la ressource est disponible à la date souhaitée
    final available = await isResourceAvailable(resourceId, date);

    if (!available) {
      throw Exception("La ressource n'est pas disponible à cette date.");
    }

    // Insérer la réservation
    await db.insert('reservations', {
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'status': 'en_attente', // Par défaut
    });
  }

  // Récupérer les réservations en attente
  Future<List<Reservation>> getPendingReservations() async {
    final db = await AppDatabase.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'status = ?',
      whereArgs: ['en_attente'],
    );

    return maps.map((r) => Reservation.fromMap(r)).toList();
  }

  // Valider ou rejeter une réservation
  Future<void> validateReservation(int reservationId, String status) async {
    final db = await AppDatabase.database;

    await db.update(
      'reservations',
      {'status': status}, // 'validée' ou 'rejetée'
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

 // Récupérer toutes les réservations
Future<List<Reservation>> getAllReservations() async {
  final db = await AppDatabase.database;

  final List<Map<String, dynamic>> maps = await db.query('reservations');

  return maps.map((r) => Reservation.fromMap(r)).toList();
}


  // Modifier une réservation
  Future<void> updateReservation({
    required int reservationId,
    required String newDate,
  }) async {
    final db = await AppDatabase.database;

    // Vérifier si la ressource est disponible à la nouvelle date
    final available = await isResourceAvailable(
      (await db.query('reservations', where: 'id = ?', whereArgs: [reservationId])).first['resourceId'] as int,
      newDate,
    );

    if (!available) {
      throw Exception("La ressource n'est pas disponible à cette nouvelle date.");
    }

    // Mettre à jour la réservation
    await db.update(
      'reservations',
      {
        'date': newDate,
        'status': 'en_attente', // Remettre en attente après modification
      },
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // Annuler une réservation
  Future<void> cancelReservation(int reservationId) async {
    final db = await AppDatabase.database;

    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }
}
