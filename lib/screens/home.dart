import 'package:flutter/material.dart';
import 'package:sqliet_task/database/database.dart';
import 'package:sqliet_task/screens/addTask.dart';

import '../modal/task.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DbHelper db = DbHelper();
  List<Task> taskList = [];
  List<Task> filteredList = [];
  final _searchController = TextEditingController();
  String segmentValue = '';

  //initialize the list with db lists
  Future<void> init() async {
    var list = await db.select();
    setState(() {
      taskList = list;
    });
    filteredList = taskList;
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Task List'),
        bottom: PreferredSize(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                margin: EdgeInsets.only(bottom: 9),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    _search(value);
                  },
                  decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      hintText: 'Search your Tasks',
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      border: OutlineInputBorder()),
                ),
              ),
              SegmentedButton(
                multiSelectionEnabled: false,
                emptySelectionAllowed: true,
                segments: [
                  ButtonSegment(
                    icon: Icon(Icons.date_range),
                    value: "DATE",
                    label: Text('Date'),
                  ),
                  ButtonSegment(
                    icon: Icon(Icons.punch_clock),
                    value: "TIME",
                    label: Text('Time'),
                  ),
                  ButtonSegment(
                    icon: Icon(Icons.priority_high),
                    value: "PRIORITY",
                    label: Text('Priority'),
                  ),
                ],
                selected: {segmentValue},
                onSelectionChanged: (p0) {
                  setState(() {
                    segmentValue = p0.first;
                  });

                  switch (segmentValue) {
                    case 'PRIORITY':
                      filteredList.sort(
                        (a, b) => int.parse(a.priority.toString())
                            .compareTo(int.parse(b.priority.toString())),
                      );
                      break;
                    case 'DATE':
                      filteredList.sort(
                        (a, b) => a.dueDate
                            .toString()
                            .compareTo(b.dueDate.toString()),
                      );
                      print(filteredList);
                      break;
                    case 'TIME':
                      filteredList.sort(
                        (a, b) => a.dueTime
                            .toString()
                            .compareTo(b.dueTime.toString()),
                      );
                      print(filteredList);
                      break;
                  }
                },
              ),
              Divider(
                thickness: 2,
                color: Colors.black54,
              ),
            ],
          ),
          preferredSize: Size.fromHeight(125),
        ),
      ),
      body: Container(
        child: taskList.isEmpty
            ? Center(
                child: Text('No Task to do..'),
              )
            : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  Task task = filteredList[index];

                  var prString = '';
                  switch (task.priority) {
                    case 0:
                      prString = 'High';
                      break;
                    case 1:
                      prString = 'Medium';
                      break;
                    case 2:
                      prString = 'Low';
                      break;
                  }

                  Color bgColor = Colors.white;
                  if (task.isCompleted == 1) {
                    bgColor = Colors.grey;
                  } else {
                    switch (task.priority) {
                      case 0:
                        bgColor = Colors.red.shade200;
                        break;
                      case 1:
                        bgColor = Colors.blue.shade200;
                        break;
                      case 2:
                        bgColor = Colors.green.shade200;
                        break;
                    }
                  }
                  return Card(
                    color: bgColor,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: task.isCompleted == 1
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              ListTile(
                                title: Text(
                                    '${task.title} : ${task.description}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                        decoration: task.isCompleted == 1
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Priority : $prString',
                                      style: TextStyle(
                                          decoration: task.isCompleted == 1
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                    Text(
                                      'Due Date : ${task.dueDate}',
                                      style: TextStyle(
                                          decoration: task.isCompleted == 1
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                    Text(
                                      'Due Time : ${task.dueTime}',
                                      style: TextStyle(
                                          decoration: task.isCompleted == 1
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 1:
                                        markComplete(task);
                                        break;
                                      case 2:
                                        updateTask(task);
                                        break;
                                      case 3:
                                        _deleteTask(task, context);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 1,
                                      child: ListTile(
                                        leading: Icon(Icons.check),
                                        title: Text(task.isCompleted == 1
                                            ? 'Mark as incompleted'
                                            : 'Mark as Completed'),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      child: ListTile(
                                        title: Text('Edit'),
                                        leading: Icon(Icons.edit),
                                      ),
                                      value: 2,
                                    ),
                                    PopupMenuItem(
                                      value: 3,
                                      child: ListTile(
                                        leading:
                                            Icon(Icons.delete_forever_outlined),
                                        title: Text('Delete'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Color.fromRGBO(255, 255, 255, 99)),
                              )),
                            ],
                          )
                        : ListTile(
                            title: Text(task.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    decoration: task.isCompleted == 1
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Priority : $prString',
                                  style: TextStyle(
                                      decoration: task.isCompleted == 1
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                                Text(
                                  'Due Date : ${task.dueDate}',
                                  style: TextStyle(
                                      decoration: task.isCompleted == 1
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                                Text(
                                  'Due Time : ${task.dueTime}',
                                  style: TextStyle(
                                      decoration: task.isCompleted == 1
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                switch (value) {
                                  case 1:
                                    markComplete(task);
                                    break;
                                  case 2:
                                    updateTask(task);
                                    break;
                                  case 3:
                                    _deleteTask(task, context);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    leading: Icon(Icons.check),
                                    title: Text(task.isCompleted == 1
                                        ? 'Mark as incompleted'
                                        : 'Mark as Completed'),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    title: Text('Edit'),
                                    leading: Icon(Icons.edit),
                                  ),
                                  value: 2,
                                ),
                                PopupMenuItem(
                                  value: 3,
                                  child: ListTile(
                                    leading:
                                        Icon(Icons.delete_forever_outlined),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                }),
      ),
      floatingActionButton: Container(
        height: 60,
        child: ElevatedButton(
          style: ButtonStyle(
              elevation: WidgetStatePropertyAll(20),
              backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
              shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(15)))),
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            Map? map = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTask(),
                ));
            if (map != null) {
              if (!map['isUpdated']) {
                setState(() {
                  filteredList.add(map['task']);
                });
                taskList.add(map['task']);
              }
            } else {}
          },
        ),
      ),
    );
  }

  void _search(String text) {
    List<Task> tempList = [];
    if (text.isNotEmpty) {
      tempList = taskList
          .where(
            (element) =>
                element.title.toLowerCase().contains(text.toLowerCase()),
          )
          .toList();
    } else {
      tempList = taskList;
    }
    setState(() {
      filteredList = tempList;
    });
  }

  _deleteTask(Task task, BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('You want to delete this task?'),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('N O'),
          ),
          FilledButton(
            onPressed: () async {
              int status = await db.deleteTask(task.id!);
              if (status > 0) {
                setState(() {
                  filteredList.removeWhere(
                    (element) => element.id == task.id,
                  );
                  taskList.removeWhere(
                    (element) => element.id == task.id,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text('Y E S'),
          ),
        ],
      ),
    );
  }

  Future<void> updateTask(Task task) async {
    Map<String, dynamic>? map = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTask(
            task: task,
          ),
        ));

    if (map != null) {
      if (map['isUpdated']) {
        Task task = map['task'];
        int index = filteredList.indexWhere(
          (element) => element.id == task.id,
        );
        setState(() {
          filteredList[index] = task;
        });
        taskList[index] = task;
      }
    }
  }

  Future<void> markComplete(Task task) async {
    if (task.isCompleted == 1) {
      task.isCompleted = 0;
    } else {
      task.isCompleted = 1;
    }

    db.updateCompleted(task).then((result) {
      if (result > 0) {
        print('Marked as complete');
        int index = filteredList.indexWhere(
          (element) => element.id == task.id,
        );
        setState(() {
          filteredList[index].isCompleted = task.isCompleted;
        });
        taskList[index].isCompleted = task.isCompleted;
      } else {
        print('Failed to mark complete');
      }
    });
  }
}
