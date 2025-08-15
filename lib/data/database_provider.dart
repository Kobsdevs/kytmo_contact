import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._();
  DatabaseProvider._();
  factory DatabaseProvider() => _instance;

  Database? _db;
  static const _dbName = 'kytmo_contact.db';
  static const _dbVersion = 1;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath(); // fourni par sqflite
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    // Log utile pour retrouver la DB en dev
    // ignore: avoid_print
    print('DB path: $path');
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Ex : if (oldVersion < 2) await db.execute('ALTER TABLE contacts ADD COLUMN note TEXT;');
  }

  Future<void> reset() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    await deleteDatabase(path); // supprime le fichier
    _db = null;
  }
}