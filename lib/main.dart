import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(ToDoApp());

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LandingPage(),
    );
  }
}

// Landing Page
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'TaskMate',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your tasks simplified',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create, manage, and conquer your to-do list with ease.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TodoListPage()),
                        );
                      },
                      child: Text('Get Started',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'List. Organize. Conquer.',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: Colors.teal[700]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// To-Do List Page with Persistence
class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<String> _tasks = [];
  Set<int> _completedIndexes = {};
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = prefs.getStringList('tasks') ?? [];
    final completedList = prefs.getString('completed') ?? '[]';

    setState(() {
      _tasks = taskList;
      _completedIndexes =
          Set<int>.from(jsonDecode(completedList).map((e) => e as int));
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
    await prefs.setString('completed', jsonEncode(_completedIndexes.toList()));
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tasks.add(text);
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _completedIndexes.remove(index);
      _tasks.removeAt(index);
      _completedIndexes = _completedIndexes
          .map((i) => i > index ? i - 1 : i)
          .toSet(); // shift indexes
    });
    _saveTasks();
  }

  void _editTask(int index) {
    TextEditingController _editController =
        TextEditingController(text: _tasks[index]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Task"),
        content: TextField(
          controller: _editController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks[index] = _editController.text.trim();
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      if (_completedIndexes.contains(index)) {
        _completedIndexes.remove(index);
      } else {
        _completedIndexes.add(index);
      }
    });
    _saveTasks();
  }

  double _getProgress() {
    if (_tasks.isEmpty) return 0;
    return _completedIndexes.length / _tasks.length;
  }

  @override
  Widget build(BuildContext context) {
    double progress = _getProgress();
    String progressText = (progress * 100).toStringAsFixed(0) + '%';

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Custom Progress Bar with percentage
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Container(
                    height: 24,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                  ),
                  Container(
                    height: 24,
                    width: MediaQuery.of(context).size.width * progress,
                    decoration: BoxDecoration(
                      color: Colors.teal,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      progressText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Enter a new task',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(14),
                  ),
                  child: Icon(Icons.add, size: 24),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Task list
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks added yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            activeColor: Colors.teal,
                            value: _completedIndexes.contains(index),
                            onChanged: (_) => _toggleTaskCompletion(index),
                          ),
                          title: Text(
                            _tasks[index],
                            style: TextStyle(
                              decoration: _completedIndexes.contains(index)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.teal),
                                onPressed: () => _editTask(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(index),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
