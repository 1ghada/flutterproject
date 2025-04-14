import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'booking.db');

    return await openDatabase(
      path,
      version: 2,  // Changer la version ici (de 1 à 2)
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,  // Ajouter une gestion de mise à jour
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT,
        role TEXT
      );
    ''');

    await db.execute(''' 
      CREATE TABLE resources (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        description TEXT,
        capacity INTEGER
      );
    ''');

    await db.execute(''' 
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        resourceId INTEGER,
        date TEXT,
        timeSlot TEXT
      );
    ''');
  }

  // Gestion de la mise à jour de la base de données
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Mise à jour de la table 'users' pour ajouter le champ 'password'
      await db.execute(''' 
        ALTER TABLE users ADD COLUMN password TEXT;
      ''');
    }
  }
}
