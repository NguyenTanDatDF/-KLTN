import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../Model/Task.dart';

void main() {
  runApp(MyApp());
}

class TaskDisplay {
  String name;
  bool isCompleted;
  DateTime date;
  String time;
  Task task;
  TaskDisplay(this.name, this.isCompleted, this.date, this.time, this.task);
}

Future<List<Task>> fetchAllTasks() async {
  final response = await http.get(Uri.parse('http://192.168.0.188:8081/api/v1/task'));

  if (response.statusCode == 200) {
    List<dynamic> jsonTasks = jsonDecode(response.body);
    print("fetch OK");
    List<Task> tasks = jsonTasks.map((json) => Task.fromJson1(json)).toList();
    print("fetch OK");
    return tasks;
  } else {
    throw Exception('Failed to load tasks');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      home: SettingScreen(),
    );
  }
}

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late List<Task> _tasksraw = [];

  @override
  void initState() {
    super.initState();
    fetchAllTasks().then((tasks) {
      setState(() {
        _tasksraw = tasks;
      });
    });
  }
  bool convertStringToBool(String value) {
    if (value.toLowerCase() == 'true') {
      return true;
    } else if (value.toLowerCase() == 'false') {
      return false;
    } else {
      throw FormatException("Invalid boolean string: $value");
    }
  }
  bool checkFieldAtIndex(List<Task> itemList, int index) {
    if (index >= 0 && index < itemList.length) {
      return itemList[index].number_of_month == "true";
    } else {
      // Trả về false nếu index không hợp lệ
      return false;
    }
  }
  DateTime convertToDate(String day, String month, String year) {
    // Chuyển đổi sang kiểu số nguyên
    int dayInt = int.parse(day);
    int monthInt = int.parse(month);
    int yearInt = int.parse(year);

    // Tạo đối tượng DateTime
    DateTime dateTime = DateTime(yearInt, monthInt, dayInt);

    return dateTime;
  }
  DateTime formatDateTime(int day, int month, int year) {
    // Trả về đối tượng DateTime
    return DateTime(year, month, day);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: _tasksraw.length,
        itemBuilder: (context, index) {
          return TaskItem(
            task: TaskDisplay(_tasksraw[index].summarize, checkFieldAtIndex(_tasksraw,index) ,convertToDate(_tasksraw[index].day,_tasksraw[index].month, DateTime.now().year.toString()),_tasksraw[index].specific_time, _tasksraw[index] ),

              onPrintOk: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Do you want to remove this task?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // Thực hiện hành động khi bấm nút Cancel
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {

                            deleteTaskByFields(_tasksraw[index].summarize,_tasksraw[index].specific_time);
                            // Gửi yêu cầu xóa task đến API ở đây

                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
          );
        },
      ),
    );
  }
}

// Hàm để gọi endpoint DELETE
Future<void> deleteTaskByFields(String a, String b) async {
  String apiUrl =  "http://192.168.0.188:8081/api/v1/task/deleteByFields";

  try {
    final response = await http.delete(
      Uri.parse('$apiUrl?value1=$a&value2=$b'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Xóa thành công');
    } else {
      print('Lỗi khi xóa: ${response.statusCode}');
    }
  } catch (error) {
    print('Lỗi khi xóa: $error');
  }

}
class TaskItem extends StatelessWidget {
  final TaskDisplay task;
  final VoidCallback onPrintOk; // Hàm sẽ chạy khi bấm nút

  TaskItem({
    required this.task,
    required this.onPrintOk,
  });

  String getCurrentTimeFormatted() {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('HH:mm:ss').format(now);
    return formattedTime;
  }

  int calculateMinutesBetweenTimes(String time1, String time2) {
    DateTime dateTime1 = DateFormat('HH:mm:ss').parse(time1);
    DateTime dateTime2 = DateFormat('HH:mm:ss').parse(time2);

    // Tính số phút cách nhau
    int minutesDifference = dateTime2.difference(dateTime1).inMinutes;

    return minutesDifference;
  }

  int calculateMinutesBetweenDates(String date1, String date2) {
    DateTime dateTime1 = DateFormat('yyyy-MM-dd').parse(date1);
    DateTime dateTime2 = DateFormat('yyyy-MM-dd').parse(date2);

    // Tính số phút cách nhau
    int minutesDifference = dateTime2.difference(dateTime1).inMinutes;

    return minutesDifference;
  }
  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }
  @override
  Widget build(BuildContext context) {
    Color cardColor;

    // Lấy thời gian hiện tại
    String now = getCurrentTimeFormatted();
    String day = task.date.toString();
    String time = task.time;
    String nowDay = getCurrentDate();
    int a = (calculateMinutesBetweenTimes(now,time));
    int b = calculateMinutesBetweenDates(nowDay,day);
    int difference = a + b;
    print("Time"+ time);
    // Chuyển đổi specific_time từ String sang DateTime
    DateTime specificTime = DateFormat('yy-MM-dd HH:mm:ss').parse('$day $time');
    print("specificTime"+ specificTime.toString());
    print("now"+ now.toString());
    // Tính toán sự chênh lệch giữa thời gian hiện tại và specific_time

    print("difference"+ difference.toString());

    // Kiểm tra điều kiện và đặt màu tương ứng
    if (difference <= 60 && difference > 0) {
      cardColor = Colors.yellow; // Nếu còn dưới 1 tiếng, đặt màu vàng
    } else if (difference <= 0) {
      cardColor = Colors.red; // Nếu thời gian đã qua, đặt màu đỏ
    } else {
      cardColor = Colors.white; // Mặc định màu trắng
    }

    return Card(
      margin: EdgeInsets.all(8.0),
      color: cardColor, // Đặt màu cho Card
      child: InkWell(
        onTap: onPrintOk,
        child: ListTile(
          title: Text(
            task.name,
            style: TextStyle(
              color: task.isCompleted ? Colors.grey : Colors.black,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            'Due Date: ${task.date.day}/${task.date.month}/${task.date.year} | ${time}', // Định dạng giờ và phút
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          trailing: Icon(Icons.delete),
        ),
      ),
    );
  }
}

