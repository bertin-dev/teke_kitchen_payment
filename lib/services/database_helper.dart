import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operator TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isSuccess INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertHistory(String operator, String description, String timeTransaction,  bool isSuccess) async {
    final db = await instance.database;
    final data = {'operator': operator, 'description': description, 'timestamp': timeTransaction, 'isSuccess': isSuccess ? 1 : 0};
    await db.insert('history', data);
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await instance.database;
    return await db.query('history', orderBy: 'id DESC');
  }

  Future<void> deleteHistory(int id) async {
    final db = await instance.database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }
}
