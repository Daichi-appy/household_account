import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'expense.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE expenses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      amount REAL,
      date TEXT
    )
    ''');
  }

  Future<int> insertExpense(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('expenses', row);
  }

  Future<List<Map<String, dynamic>>> queryAllExpenses() async {
    Database db = await database;
    return await db.query('expenses');
  }

  Future<int> updateExpense(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('expenses', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
