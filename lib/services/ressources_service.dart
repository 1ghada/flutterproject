import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/resource.dart';

class ResourceService {
  Future<void> insertResource(Resource resource) async {
    final db = await AppDatabase.database;
    await db.insert(
      'resources',
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Resource>> getAllResources() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('resources');

    return List.generate(maps.length, (i) {
      return Resource.fromMap(maps[i]);
    });
  }

  Future<void> updateResource(Resource resource) async {
    final db = await AppDatabase.database;
    await db.update(
      'resources',
      resource.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  Future<void> deleteResource(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
