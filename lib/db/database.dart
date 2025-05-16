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
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 6, // ⬅️ Mise à jour de version pour ajouter la table de notifications
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
        capacity INTEGER,
        requiresValidation INTEGER DEFAULT 0 -- ⬅️ 0 : non, 1 : oui
      );
    ''');

    await db.execute('''
      CREATE TABLE reservations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        resourceId INTEGER,
        date TEXT,
        timeSlot TEXT,
        status TEXT DEFAULT 'en_attente', -- ⬅️ en_attente, validée, refusée
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (resourceId) REFERENCES resources(id)
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

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        title TEXT,
        message TEXT,
        createdAt TEXT,
        isRead INTEGER DEFAULT 0, -- ⬅️ 0 : non lu, 1 : lu
        type TEXT,
        relatedId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE resources ADD COLUMN requiresValidation INTEGER DEFAULT 0;
      ''');

      await db.execute('''
        ALTER TABLE reservations ADD COLUMN status TEXT DEFAULT 'en_attente';
      ''');
    }

    if (oldVersion < 6) {
      // Création de la table de notifications
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          title TEXT,
          message TEXT,
          createdAt TEXT,
          isRead INTEGER DEFAULT 0,
          type TEXT,
          relatedId INTEGER,
          FOREIGN KEY (userId) REFERENCES users(id)
        );
      ''');
    }
  }
}
