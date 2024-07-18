import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqliet_task/modal/task.dart';

class DbHelper {
  static final DbHelper _dbhelper = DbHelper._internal();
  final String dbName = 'taskDB';
  DbHelper._internal();
  final tableName = 'tasks';
  factory DbHelper() {
    return _dbhelper;
  }

  Database? database;

  Future<Database> _getDatabase() async {
    return database ??= await _createDatabase();
  }

  Future<Database> _createDatabase() async {
    String path = join(await getDatabasesPath(), dbName);

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE ${tableName}(id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'title TEXT,'
            'description TEXT,'
            'priority INTEGER,'
            'dueDate TEXT,'
            'dueTime TEXT);');
      },
      version: 1,
    );
  }

  Future<int> insert(Task task) async {
    int result = 0;
    try {
      var db = await _dbhelper._getDatabase();
      result = await db.insert(
        tableName,
        task.toMap(),
      );
    } catch (e) {
      print(e.toString());
    }

    return result;
  }

  Future<int> update(Task task) async {
    int result = 0;
    try {
      var db = await _dbhelper._getDatabase();
      result = await db.update(tableName, task.toMap(),
          where: 'id = ?', whereArgs: [task.id]);

      print('Update Successfully');
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List<Task>> select() async {
    List<Task> list = [];
    try {
      var db = await _dbhelper._getDatabase();
      List<Map<String, dynamic>> mapList = await db.query(' tasks;');
      print(mapList);
      print('got DB');
      for (int i = 0; i < mapList.length; i++) {
        list.add(Task.fromMap(mapList[i]));
      }
      print('converted to string');
    } catch (e) {
      print(e.toString());
    }
    return list;
  }

  Future<int> deleteTask(int id) async {
    int status = 0;
    try {
      var db = await _dbhelper._getDatabase();
      status = await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
      print(status);
    } catch (e) {
      print(e.toString());
    }
    return status;
  }
}
