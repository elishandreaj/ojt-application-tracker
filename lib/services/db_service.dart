import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  /// Singleton instance of the `DatabaseService`.
  static final DatabaseService _instance = DatabaseService._internal();

  /// SQLite database instance.
  static Database? _database;

  /// Factory constructor to return the singleton instance.
  factory DatabaseService() => _instance;

  /// Private constructor for the singleton pattern.
  DatabaseService._internal();

  /// Getter to initialize and return the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initializes the SQLite database.
  Future<Database> _initDB() async {
    // Path to the database file.
    String path = join(await getDatabasesPath(), 'applications.db');

    // Open the database and create the `applications` table if it doesn't exist.
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
            setup TEXT NOT NULL,
            status TEXT NOT NULL,
            date TEXT NOT NULL,
            date_added TEXT,
            notes TEXT,
            requirements TEXT  
          )
        ''');
      },
    );
  }

  /// Fetches all applications from the database.
  ///
  /// Returns a list of maps where each map represents an application.
  Future<List<Map<String, dynamic>>> fetchApplications() async {
    final db = await database;
    return await db.query('applications');
  }

  /// Inserts a new application into the database.
  ///
  /// [app] is a map containing the application data to be inserted.
  Future<void> insertApplication(Map<String, dynamic> app) async {
    final db = await database;
    await db.insert('applications', app);
  }

  /// Deletes an application from the database by its ID.
  ///
  /// [id] is the ID of the application to be deleted.
  Future<void> deleteApplication(int id) async {
    final db = await database;
    await db.delete(
      'applications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Updates an existing application in the database.
  ///
  /// [id] is the ID of the application to be updated.
  /// [updatedData] is a map containing the updated application data.
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