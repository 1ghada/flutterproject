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

    // ❗️Supprimer la base de données pour forcer sa recréation (développement uniquement)
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 4, // ⬅️ version mise à jour
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
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

    await db.execute('''
      CREATE TABLE time_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        resourceId INTEGER,
        startTime TEXT,
        endTime TEXT,
        FOREIGN KEY (resourceId) REFERENCES resources(id)
      );
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS time_slots (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          resourceId INTEGER,
          startTime TEXT,
          endTime TEXT,
          FOREIGN KEY (resourceId) REFERENCES resources(id)
        );
      ''');
    }
  }
}
