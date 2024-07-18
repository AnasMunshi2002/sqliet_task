class Task {
  int? id;
  String title;
  String description;
  int priority;
  String dueDate;
  String dueTime;

  Task(
      {required this.title,
      required this.description,
      required this.priority,
      required this.dueDate,
      required this.dueTime,
      this.id});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate,
      'dueTime': dueTime,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        priority: map['priority'],
        dueDate: map['dueDate'],
        dueTime: map['dueTime']);
  }
}
