import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Todo {
  int? id;
  String title;
  int isDone;

  Todo({this.id, required this.title, this.isDone = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_db.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)');
      },
    );
  }

  Future<int> insert(Todo todo) async {
    final db = await instance.database;
    return await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getAll() async {
    final db = await instance.database;
    final maps = await db.query('todos', orderBy: 'id DESC');
    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'] as int,
        title: maps[i]['title'] as String,
        isDone: maps[i]['isDone'] as int,
      );
    });
  }

  Future<int> update(Todo todo) async {
    final db = await instance.database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}