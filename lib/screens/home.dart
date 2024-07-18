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
  List<Task> tasklist = [];
  var _searchController = TextEditingController();
  String segementValue = '';

  //initialize the list with db lists
  Future<void> init() async {
    var list = await db.select();
    setState(() {
      tasklist = list;
    });
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
                  onChanged: (value) {},
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
                selected: {segementValue},
                onSelectionChanged: (p0) {
                  setState(() {
                    segementValue = p0.first;
                  });
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
        child: tasklist.isEmpty
            ? Center(
                child: Text('No Task to do..'),
              )
            : ListView.builder(
                itemCount: tasklist.length,
                itemBuilder: (context, index) {
                  /*String todayDate = DateTime.now().toString().split(' ')[0];
                  String todayTime = TimeOfDay.now().toString();
                  bool isDue = (todayDate.compareTo(tasklist[index].dueDate) ==
                              -1 &&
                          todayTime.compareTo(tasklist[index].dueTime) == -1)
                      ? true
                      : false;*/

                  switch (segementValue) {
                    case 'PRIORITY':
                      tasklist.sort(
                        (a, b) => int.parse(a.priority.toString())
                            .compareTo(int.parse(b.priority.toString())),
                      );
                      break;
                    case 'DATE':
                      tasklist.sort(
                        (a, b) => a.dueDate
                            .toString()
                            .compareTo(b.dueDate.toString()),
                      );
                      break;
                    case 'TIME':
                      tasklist.sort(
                        (a, b) => a.dueTime
                            .toString()
                            .compareTo(b.dueTime.toString()),
                      );
                      break;
                  }
                  var prString = '';
                  switch (tasklist[index].priority) {
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
                  /*if (!isDue) {
                    bgColor = Colors.blueAccent;
                  } else {

                  }*/
                  switch (tasklist[index].priority) {
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
                  return Card(
                    color: bgColor,
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: ListTile(
                      title: Text(tasklist[index].title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 26)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Priority : $prString'),
                          Text('Due Date : ${tasklist[index].dueDate}'),
                          Text('Due Time : ${tasklist[index].dueTime}'),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          switch (value) {
                            case 1:
                              updateTask(tasklist[index]);
                              break;
                            case 2:
                              _deleteTask(tasklist[index], context);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.check),
                              title: Text('Mark as Completed'),
                            ),
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              title: Text('Edit'),
                              leading: Icon(Icons.edit),
                            ),
                            value: 1,
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: ListTile(
                              leading: Icon(Icons.delete_forever_outlined),
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
                  tasklist.add(map['task']);
                });
              }
            } else {}
          },
        ),
      ),
    );
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
                  tasklist.removeWhere(
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
        int index = tasklist.indexWhere(
          (element) => element.id == task.id,
        );
        setState(() {
          tasklist[index] = task;
        });
      }
    }
  }
}
