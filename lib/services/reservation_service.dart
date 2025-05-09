import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/reservation.dart';

class ReservationService {
  // 1. Vérifier les créneaux disponibles pour une ressource donnée à une date précise
  Future<List<String>> getAvailableTimeSlots(int resourceId, String date) async {
    final db = await AppDatabase.database;

    // 1.1. Récupérer tous les créneaux pour la ressource
    final slots = await db.query('time_slots', where: 'resourceId = ?', whereArgs: [resourceId]);

    // 1.2. Récupérer les créneaux déjà réservés pour cette ressource et date
    final reserved = await db.query('reservations', where: 'resourceId = ? AND date = ?', whereArgs: [resourceId, date]);

    List<String> reservedSlots = reserved.map((r) => r['timeSlot'] as String).toList();

    // 1.3. Vérifier les créneaux disponibles
    List<String> available = [];
    for (var s in slots) {
      String slot = "${s['startTime']}-${s['endTime']}";
      if (!reservedSlots.contains(slot)) {
        available.add(slot);
      }
    }

    return available;
  }

  // 2. Effectuer une réservation pour un utilisateur
  Future<void> reserve({
    required int userId,
    required int resourceId,
    required String date,
    required String timeSlot,
  }) async {
    final db = await AppDatabase.database;

    // 2.1. Insérer la réservation dans la base de données
    await db.insert('reservations', {
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'timeSlot': timeSlot,
      'status': 'en_attente', // Par défaut, la réservation est en attente
    });
  }

  // 3. Récupérer toutes les réservations en attente de validation par le manager
  Future<List<Reservation>> getPendingReservations() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'status = ?',
      whereArgs: ['en_attente'],
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  // 4. Mettre à jour le statut d'une réservation (validation ou rejet par le manager)
  Future<void> validateReservation(int reservationId, String status) async {
    final db = await AppDatabase.database;

    // 4.1. Mettre à jour le statut de la réservation
    await db.update(
      'reservations',
      {'status': status}, // 'validée' ou 'rejetée'
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // 5. Récupérer toutes les réservations d'un utilisateur spécifique
  Future<List<Reservation>> getUserReservations(int userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reservations',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return Reservation.fromMap(maps[i]);
    });
  }

  // 6. Modifier une réservation existante (changer la date ou le créneau)
  Future<void> updateReservation({
    required int reservationId,
    required String newDate,
    required String newTimeSlot,
  }) async {
    final db = await AppDatabase.database;

    // 6.1. Mettre à jour la réservation avec la nouvelle date et créneau
    await db.update(
      'reservations',
      {
        'date': newDate,
        'timeSlot': newTimeSlot,
      },
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }

  // 7. Annuler une réservation
  Future<void> cancelReservation(int reservationId) async {
    final db = await AppDatabase.database;

    // 7.1. Supprimer la réservation de la base de données
    await db.delete(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );
  }
}
