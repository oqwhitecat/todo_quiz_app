import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(const MaterialApp(home: TodoApp(), debugShowCheckedModeBanner: false));

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<Todo> _todos = [];

  void _refresh() async {
    final data = await DatabaseHelper.instance.getAll();
    setState(() { _todos = data; });
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _showForm({Todo? todo}) {
    final controller = TextEditingController(text: todo?.title ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(todo == null ? 'เพิ่มงานใหม่' : 'แก้ไขงาน'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'ชื่องาน...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              if (todo == null) {
                await DatabaseHelper.instance.insert(Todo(title: controller.text));
              } else {
                todo.title = controller.text;
                await DatabaseHelper.instance.update(todo);
              }
              if (mounted) Navigator.pop(ctx);
              _refresh();
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _todos.where((t) => t.isDone == 0).toList();
    final finished = _todos.where((t) => t.isDone == 1).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List Quiz')),
      body: ListView(
        children: [
          _buildHeader('งานที่ยังค้างอยู่', Colors.orange, pending.length),
          ...pending.map((t) => _buildTodoTile(t)),
          const Divider(),
          _buildHeader('งานที่เสร็จแล้ว (ขีดฆ่า)', Colors.green, finished.length),
          ...finished.map((t) => _buildTodoTile(t)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(String title, Color color, int count) {
    return ListTile(
      title: Text('$title ($count)', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
    );
  }

  Widget _buildTodoTile(Todo todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone == 1,
          onChanged: (v) async {
            todo.isDone = v! ? 1 : 0;
            await DatabaseHelper.instance.update(todo);
            _refresh();
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(decoration: todo.isDone == 1 ? TextDecoration.lineThrough : null),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(todo: todo)),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await DatabaseHelper.instance.delete(todo.id!);
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}