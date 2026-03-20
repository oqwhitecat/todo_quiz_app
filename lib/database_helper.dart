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
  
  // สร้างตัวแปรเก็บข้อมูลชั่วคราวสำหรับรันบน Web (เพื่อไม่ให้แอปค้าง)
  final List<Todo> _webStorage = [];

  Future<Database?> get database async {
    if (kIsWeb) return null; // ถ้าเป็น Web ไม่ต้องเปิด SQLite
    if (_database != null) return _database!;
    _database = await openDatabase(join(await getDatabasesPath(), 'quiz.db'), version: 1, 
      onCreate: (db, v) => db.execute('CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)'));
    return _database;
  }

  Future<int> insert(Todo t) async {
    if (kIsWeb) { _webStorage.add(t); return 1; }
    return await (await database)!.insert('todos', t.toMap());
  }

  Future<List<Todo>> getAll() async {
    if (kIsWeb) return _webStorage;
    final res = await (await database)!.query('todos', orderBy: 'id DESC');
    return res.map((m) => Todo(id: m['id'] as int, title: m['title'] as String, isDone: m['isDone'] as int)).toList();
  }

  Future<int> update(Todo t) async {
    if (kIsWeb) return 1;
    return await (await database)!.update('todos', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    if (kIsWeb) { _webStorage.removeWhere((item) => item.id == id); return 1; }
    return await (await database)!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}