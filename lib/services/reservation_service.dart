import 'package:flutter_booking/db/database.dart';
import 'package:flutter_booking/models/reservation.dart';
import 'package:flutter_booking/services/notification_service.dart';
import 'package:flutter_booking/services/ressources_service.dart';

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
    String timeSlot = 'Journée', // Valeur par défaut pour le créneau horaire
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
      'timeSlot': timeSlot, // Ajout du créneau horaire
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
    final notificationService = NotificationService();
    final resourceService = ResourceService();

    // Récupérer les informations de la réservation
    final List<Map<String, dynamic>> reservationMaps = await db.query(
      'reservations',
      where: 'id = ?',
      whereArgs: [reservationId],
    );

    if (reservationMaps.isEmpty) {
      throw Exception('Réservation non trouvée');
    }

    final reservation = Reservation.fromMap(reservationMaps.first);

    // Récupérer le nom de la ressource
    final resource = await resourceService.getResourceById(reservation.resourceId);
    final resourceName = resource?.name ?? 'Ressource #${reservation.resourceId}';

    // Mettre à jour le statut de la réservation
    await db.update(
      'reservations',
      {'status': status}, // 'validée' ou 'rejetée'
      where: 'id = ?',
      whereArgs: [reservationId],
    );

    // Créer une notification pour l'utilisateur
    if (status == 'validée') {
      await notificationService.createReservationValidatedNotification(
        userId: reservation.userId,
        reservationId: reservationId,
        resourceName: resourceName,
        date: reservation.date,
      );
    } else if (status == 'rejetée') {
      await notificationService.createReservationRejectedNotification(
        userId: reservation.userId,
        reservationId: reservationId,
        resourceName: resourceName,
        date: reservation.date,
      );
    }
  }

 // Récupérer toutes les réservations
Future<List<Reservation>> getAllReservations() async {
  final db = await AppDatabase.database;

  // Vérifier et mettre à jour les réservations sans timeSlot
  await _updateReservationsWithoutTimeSlot();

  final List<Map<String, dynamic>> maps = await db.query('reservations');

  return maps.map((r) => Reservation.fromMap(r)).toList();
}

// Récupérer les réservations d'un utilisateur spécifique
Future<List<Reservation>> getUserReservations(int userId) async {
  final db = await AppDatabase.database;

  // Vérifier et mettre à jour les réservations sans timeSlot
  await _updateReservationsWithoutTimeSlot();

  final List<Map<String, dynamic>> maps = await db.query(
    'reservations',
    where: 'userId = ?',
    whereArgs: [userId],
  );

  return maps.map((r) => Reservation.fromMap(r)).toList();
}

// Mettre à jour les réservations qui n'ont pas de timeSlot
Future<void> _updateReservationsWithoutTimeSlot() async {
  final db = await AppDatabase.database;

  // Vérifier s'il y a des réservations sans timeSlot
  final List<Map<String, dynamic>> reservationsWithoutTimeSlot = await db.rawQuery(
    "SELECT * FROM reservations WHERE timeSlot IS NULL OR timeSlot = ''"
  );

  // Mettre à jour ces réservations avec une valeur par défaut
  if (reservationsWithoutTimeSlot.isNotEmpty) {
    for (var reservation in reservationsWithoutTimeSlot) {
      await db.update(
        'reservations',
        {'timeSlot': 'Journée'},
        where: 'id = ?',
        whereArgs: [reservation['id']],
      );
    }
  }
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
