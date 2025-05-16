import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/resource.dart';

class ResourceService {
  // 1. Insérer une ressource
  Future<void> insertResource(Resource resource) async {
    final db = await AppDatabase.database;
    await db.insert(
      'resources',
      resource.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. Récupérer toutes les ressources
  Future<List<Resource>> getAllResources() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query('resources');

    return List.generate(maps.length, (i) {
      return Resource.fromMap(maps[i]);
    });
  }

  // 3. Récupérer les ressources nécessitant une validation
  Future<List<Resource>> getResourcesRequiringValidation() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'requiresValidation = ?',
      whereArgs: [1], // Récupérer les ressources nécessitant une validation
    );

    return List.generate(maps.length, (i) {
      return Resource.fromMap(maps[i]);
    });
  }

  // 4. Mettre à jour une ressource
  Future<void> updateResource(Resource resource) async {
    final db = await AppDatabase.database;
    await db.update(
      'resources',
      resource.toMap(),
      where: 'id = ?',
      whereArgs: [resource.id],
    );
  }

  // 5. Supprimer une ressource
  Future<void> deleteResource(int id) async {
    final db = await AppDatabase.database;
    await db.delete(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 6. Récupérer une ressource par son ID
  Future<Resource?> getResourceById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'resources',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return Resource.fromMap(maps.first);
  }
}
