import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _dbName = 'kytmo_contact.db';
  static const _version = 1;

  static Future<Database> get database async {
    final base = await getDatabasesPath();
    final path = join(base, _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            email TEXT,
            company TEXT,
            address TEXT,
            favorite INTEGER DEFAULT 0,
            created_at TEXT,
            updated_at TEXT
          );
        ''');
      },
    );
  }
}