import 'package:flutter/material.dart';
import 'package:sqliet_task/database/database.dart';

import '../modal/task.dart';

class AddTask extends StatefulWidget {
  Task? task;

  AddTask({this.task});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  var _tasktitle = TextEditingController();
  var _taskDescription = TextEditingController();
  var selectedDate = DateTime.now().toString();
  var selectedTime = TimeOfDay.now().toString();
  var priority = '';

  DbHelper db = DbHelper();
  void _storeTask(BuildContext context, Task task) {
    db.insert(task).then((result) {
      if (result != 0) {
        task.id = result;
        print('Successfull');
        Navigator.pop(context, {'task': task, 'isUpdated': false});
      } else {
        print('Failed');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Task? task = widget.task;
    if (task != null) {
      _tasktitle.text = task.title;
      _taskDescription.text = task.description;
      selectedDate = task.dueDate;
      selectedTime = task.dueTime;
      switch (task.priority) {
        case 0:
          priority = 'High';
          break;
        case 1:
          priority = 'Medium';
          break;
        case 2:
          priority = 'Low';
          break;
      }
    }
  }

  void _updateTask(BuildContext context, Task task) {
    db.update(task).then((result) {
      if (result > 0) {
        Navigator.pop(context, {'task': task, 'isUpdated': true});
      } else {
        print('Update unsuccessful');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Update Task' : 'Add Task'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Badge(
                          child: Text('Title'),
                          backgroundColor: Colors.transparent,
                          label: Text(
                            '*',
                            style: TextStyle(fontSize: 17, color: Colors.red),
                          ),
                          padding: EdgeInsets.only(left: 15),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: _tasktitle,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Enter Task title'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Description'),
                        SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          maxLines: 5,
                          controller: _taskDescription,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 13, vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Enter Task description'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Denote Priority'),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: 'High',
                                  groupValue: priority,
                                  onChanged: (value) {
                                    setState(() {
                                      priority = value!;
                                    });
                                  },
                                ),
                                Text('High'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 'Medium',
                                  groupValue: priority,
                                  onChanged: (value) {
                                    setState(() {
                                      priority = value!;
                                    });
                                  },
                                ),
                                Text('Medium'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: 'Low',
                                  groupValue: priority,
                                  onChanged: (value) {
                                    setState(() {
                                      priority = value!;
                                    });
                                  },
                                ),
                                Text('Low'),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add due Date : ${selectedDate.toString().split(' ')[0]}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              var outputDate = await showDialog(
                                  context: context,
                                  builder: (context) => DatePickerDialog(
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2050),
                                        currentDate: DateTime.now(),
                                      ));
                              selectedDate = outputDate.toString();
                              setState(() {});
                            },
                            style: ButtonStyle(),
                            child: Text('Select date'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add due time : ${selectedTime.toString()}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              var outputTime = await showDialog(
                                  context: context,
                                  builder: (context) => TimePickerDialog(
                                        initialTime: TimeOfDay.now(),
                                      ));
                              selectedTime = outputTime.toString();
                              setState(() {});
                            },
                            style: ButtonStyle(),
                            child: Text('Select time'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                      shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(100),
                              bottomLeft: Radius.circular(100))))),
                  onPressed: () {
                    String title = _tasktitle.text;
                    String description = _taskDescription.text;
                    int priorityInt = 0;
                    switch (priority) {
                      case 'High':
                        priorityInt = 0;
                        break;
                      case 'Medium':
                        priorityInt = 1;
                        break;
                      case 'Low':
                        priorityInt = 2;
                        break;
                    }
                    print('''
                    title : $title,
                    desc : $description
                    priority : $priorityInt
                    dueDate : $selectedDate,
                    dueTime : ${selectedTime.toString().substring(10, selectedTime.toString().length - 1)}
                    ''');

                    Task task = Task(
                        id: widget.task?.id,
                        title: title,
                        description: description,
                        priority: priorityInt,
                        dueDate: selectedDate.toString().split(' ')[0],
                        dueTime: selectedTime.toString());

                    if (widget.task != null) {
                      _updateTask(context, task);
                    } else {
                      _storeTask(context, task);
                    }
                  },
                  child: Text(widget.task != null
                      ? 'U p d a t e  T a s k'.toUpperCase()
                      : 'A d d  T a s k'.toUpperCase()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
