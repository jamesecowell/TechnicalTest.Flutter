import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Helper class for database initialization and management
class DatabaseHelper {
  static const _databaseName = 'posts_database.db';
  static const _databaseVersion = 1;
  static const _tableName = 'posts';

  // Make this a singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL
      )
    ''');
  }
}

