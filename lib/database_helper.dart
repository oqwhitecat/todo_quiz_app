import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // เพิ่มบรรทัดนี้

class Todo {
  int? id; String title; int isDone;
  Todo({this.id, required this.title, this.isDone = 0});
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'isDone': isDone};
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  
  // สร้าง List ไว้กั๊กงานกรณีรันบนเว็บ (เพราะบนเว็บใช้ SQLite ไม่ได้)
  List<Todo> _webTodos = []; 

  Future<Database?> get database async {
    if (kIsWeb) return null; // ถ้าเป็นเว็บ ไม่ต้องเปิด DB
    if (_database != null) return _database!;
    _database = await _initDB('quiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    return await openDatabase(join(await getDatabasesPath(), filePath), version: 1, 
      onCreate: (db, v) => db.execute('CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)'));
  }

  Future<int> insert(Todo t) async {
    if (kIsWeb) { _webTodos.add(t); return 1; }
    return await (await database)!.insert('todos', t.toMap());
  }

  Future<List<Todo>> getAll() async {
    if (kIsWeb) return _webTodos;
    final res = await (await database)!.query('todos', orderBy: 'id DESC');
    return res.map((m) => Todo(id: m['id'] as int, title: m['title'] as String, isDone: m['isDone'] as int)).toList();
  }

  Future<int> update(Todo t) async {
    if (kIsWeb) return 1;
    return await (await database)!.update(t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    if (kIsWeb) { _webTodos.removeWhere((t) => t.id == id); return 1; }
    return await (await database)!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}