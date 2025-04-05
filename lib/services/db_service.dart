import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'applications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE applications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            company TEXT NOT NULL,
            role TEXT NOT NULL,
            location TEXT NOT NULL,
            setup TEXT,
            status TEXT,
            date TEXT,
            date_added TEXT,
            notes TEXT,
            requirements TEXT  
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    final db = await database;
    return await db.query('applications');
  }

  Future<void> insertApplication(Map<String, dynamic> app) async {
    final db = await database;
    await db.insert('applications', app);
  }

  Future<void> deleteApplication(int id) async {
    final db = await database;
    await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateApplication(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
      await db.update(
        'applications',
        updatedData,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
}