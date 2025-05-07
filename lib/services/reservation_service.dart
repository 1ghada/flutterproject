import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/reservation.dart';

class ReservationService {
  Future<List<String>> getAvailableTimeSlots(int resourceId, String date) async {
    final db = await AppDatabase.database;

    // 1. Get all time slots for the resource
    final slots = await db.query('time_slots',
        where: 'resourceId = ?', whereArgs: [resourceId]);

    // 2. Get reserved time slots on that date
    final reserved = await db.query('reservations',
        where: 'resourceId = ? AND date = ?', whereArgs: [resourceId, date]);

    List<String> reservedSlots = reserved.map((r) => r['timeSlot'] as String).toList();

    // 3. Return available slots
    List<String> available = [];
    for (var s in slots) {
      String slot = "${s['startTime']}-${s['endTime']}";
      if (!reservedSlots.contains(slot)) {
        available.add(slot);
      }
    }
    return available;
  }

  Future<void> reserve({
    required int userId,
    required int resourceId,
    required String date,
    required String timeSlot,
  }) async {
    final db = await AppDatabase.database;
    await db.insert('reservations', {
      'userId': userId,
      'resourceId': resourceId,
      'date': date,
      'timeSlot': timeSlot,
    });
  }
}
