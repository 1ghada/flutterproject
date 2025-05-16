import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/notification.dart';

class NotificationService {
  // Créer une nouvelle notification
  Future<int> createNotification(UserNotification notification) async {
    final db = await AppDatabase.database;
    return await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer toutes les notifications d'un utilisateur
  Future<List<UserNotification>> getUserNotifications(int userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC', // Les plus récentes en premier
    );

    return List.generate(maps.length, (i) {
      return UserNotification.fromMap(maps[i]);
    });
  }

  // Récupérer les notifications non lues d'un utilisateur
  Future<List<UserNotification>> getUnreadNotifications(int userId) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'userId = ? AND isRead = ?',
      whereArgs: [userId, 0],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return UserNotification.fromMap(maps[i]);
    });
  }

  // Compter les notifications non lues d'un utilisateur
  Future<int> countUnreadNotifications(int userId) async {
    final db = await AppDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE userId = ? AND isRead = 0',
      [userId],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    final db = await AppDatabase.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Marquer toutes les notifications d'un utilisateur comme lues
  Future<void> markAllAsRead(int userId) async {
    final db = await AppDatabase.database;
    await db.update(
      'notifications',
      {'isRead': 1},
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    final db = await AppDatabase.database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // Créer une notification pour une réservation validée
  Future<void> createReservationValidatedNotification({
    required int userId,
    required int reservationId,
    required String resourceName,
    required String date,
  }) async {
    final notification = UserNotification(
      userId: userId,
      title: 'Réservation validée',
      message: 'Votre réservation pour "$resourceName" le $date a été validée.',
      createdAt: DateTime.now(),
      type: 'reservation_validated',
      relatedId: reservationId,
    );

    await createNotification(notification);
  }

  // Créer une notification pour une réservation rejetée
  Future<void> createReservationRejectedNotification({
    required int userId,
    required int reservationId,
    required String resourceName,
    required String date,
  }) async {
    final notification = UserNotification(
      userId: userId,
      title: 'Réservation rejetée',
      message: 'Votre réservation pour "$resourceName" le $date a été rejetée.',
      createdAt: DateTime.now(),
      type: 'reservation_rejected',
      relatedId: reservationId,
    );

    await createNotification(notification);
  }
}
