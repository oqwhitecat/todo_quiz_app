import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Todo {
  int? id;
  String title;
  int isDone;
  Todo({this.id, required this.title, this.isDone = 0});
  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'isDone': isDone};
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(join(await getDatabasesPath(), 'quiz.db'), version: 1, 
      onCreate: (db, v) => db.execute('CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)'));
    return _database!;
  }
  Future<int> insert(Todo t) async => (await database).insert('todos', t.toMap());
  Future<List<Todo>> getAll() async {
    final res = await (await database).query('todos', orderBy: 'id DESC');
    return res.map((m) => Todo(id: m['id'] as int, title: m['title'] as String, isDone: m['isDone'] as int)).toList();
  }
  Future<int> update(Todo t) async => (await database).update(t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  Future<int> delete(int id) async => (await database).delete('todos', where: 'id = ?', whereArgs: [id]);
}
