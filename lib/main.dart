import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('todoBox'); // Open a box for storing tasks
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final _todoController = TextEditingController();
  final _todoBox = Hive.box('todoBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _todoBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('No tasks added yet!'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index) as String;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(task),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(index),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddTaskDialog(),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task'),
        content: TextField(
          controller: _todoController,
          decoration: InputDecoration(hintText: 'Enter task here'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              _todoController.clear();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (_todoController.text.isNotEmpty) {
                _addTask(_todoController.text);
                Navigator.of(context).pop();
                _todoController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  void _addTask(String task) {
    _todoBox.add(task);
    setState(() {});
  }

  void _deleteTask(int index) {
    _todoBox.deleteAt(index);
    setState(() {});
  }
}