import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() => runApp(MaterialApp(home: TodoApp(), debugShowCheckedModeBanner: false));

class TodoApp extends StatefulWidget { @override _TodoAppState createState() => _TodoAppState(); }
class _TodoAppState extends State<TodoApp> {
  List<Todo> _todos = [];
  void _refresh() async { final d = await DatabaseHelper.instance.getAll(); setState(() => _todos = d); }
  @override void initState() { super.initState(); _refresh(); }

  _showForm({Todo? todo}) {
    var con = TextEditingController(text: todo?.title ?? '');
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text(todo == null ? 'เพิ่มงาน' : 'แก้ไขงาน'),
      content: TextField(controller: con),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: Text('ยกเลิก')),
        ElevatedButton(onPressed: () async {
          if (todo == null) await DatabaseHelper.instance.insert(Todo(title: con.text));
          else { todo.title = con.text; await DatabaseHelper.instance.update(todo); }
          Navigator.pop(c); _refresh();
        }, child: Text('บันทึก'))
      ],
    ));
  }

  @override Widget build(BuildContext context) {
    final p = _todos.where((t) => t.isDone == 0).toList();
    final f = _todos.where((t) => t.isDone == 1).toList();
    return Scaffold(
      appBar: AppBar(title: Text('To-Do Quiz')),
      body: ListView(children: [
        ListTile(title: Text("งานที่ค้าง (${p.length})", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
        ...p.map((t) => _tile(t)),
        Divider(),
        ListTile(title: Text("เสร็จแล้ว (${f.length})", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
        ...f.map((t) => _tile(t)),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: () => _showForm(), child: Icon(Icons.add)),
    );
  }

  Widget _tile(Todo t) => Card(child: ListTile(
    leading: Checkbox(value: t.isDone == 1, onChanged: (v) async { t.isDone = v! ? 1 : 0; await DatabaseHelper.instance.update(t); _refresh(); }),
    title: Text(t.title, style: TextStyle(decoration: t.isDone == 1 ? TextDecoration.lineThrough : null)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(todo: t)),
      IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async { await DatabaseHelper.instance.delete(t.id!); _refresh(); }),
    ]),
  ));
}
