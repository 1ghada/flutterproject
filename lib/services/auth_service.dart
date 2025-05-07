import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../db/database.dart';
import '../models/user.dart';

class AuthService {
  // Enregistrement d’un nouvel utilisateur
  Future<void> registerUser(User user) async {
    final db = await AppDatabase.database;

    await db.insert(
      'users',
      user.toJson(), // ← Utilise toJson() pour insérer
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Connexion d’un utilisateur avec email et mot de passe
  Future<User?> loginUser(String email, String password) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      final user = User.fromJson(result.first);

      // Stocker l'ID de l'utilisateur dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id!);

      return user;
    } else {
      return null;
    }
  }
  // Récupérer tous les utilisateurs (utile pour debug)
  Future<List<User>> getAllUsers() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> result = await db.query('users');

    return result.map((userMap) => User.fromJson(userMap)).toList();
  }

  // Supprimer un utilisateur par ID
  Future<void> deleteUser(String id) async {
    final db = await AppDatabase.database;

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    final db = await AppDatabase.database;

    await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
  // Récupérer l'ID de l'utilisateur connecté par email
  Future<int?> getUserId(String email) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int?;  // Assurez-vous que l'ID est de type int
    } else {
      return null;  // Aucun utilisateur trouvé
    }
  }
  
}
