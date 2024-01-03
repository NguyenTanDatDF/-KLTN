import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import '../Model/Task.dart';
import 'dart:math';
import 'dart:ui';

void main() {
  return runApp(CalendarApp());
}

/// The app which hosts the home page which contains the calendar on it.
class CalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const MyHomePage(),
    );
  }
}

/// The hove page which hosts the calendar
class MyHomePage extends StatefulWidget {
  /// Creates the home page to display teh calendar widget.
  const MyHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool _isLoading = true;
  late List<Task> _tasks = []; // Biến thành viên để lưu danh sách Task

  @override
  void initState() {
    super.initState();
    fetchAllTasks().then((tasks) {
      setState(() {
        _tasks = tasks; // Lưu danh sách Task vào biến thành viên
      });
    });
  }




  Future<List<Task>> fetchAllTasks() async {
    final response = await http.get(
        Uri.parse('http://192.168.0.188:8081/api/v1/task'));

    if (response.statusCode == 200) {
      // Đã lấy được dữ liệu từ API thành công
      List<dynamic> jsonTasks = jsonDecode(response.body);
      print("fetch OK");
      // Chuyển đổi danh sách json thành danh sách các đối tượng Task
      List<Task> tasks = jsonTasks.map((json) => Task.fromJson1(json)).toList();

      print("fetch OK");
      return tasks;
    } else {
      // Xử lý lỗi nếu có
      throw Exception('Failed to load tasks');
    }
  }

  CalendarView calendarView = CalendarView.month; // Giá trị mặc định

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blue, // Màu sắc có thể điều chỉnh tùy ý
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<CalendarView>(
                  onSelected: (CalendarView value) {
                    setState(() {
                      calendarView = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: CalendarView.day,
                        child: Text('Day'),
                      ),
                      PopupMenuItem(
                        value: CalendarView.month,
                        child: Text('Month'),
                      ),
                      PopupMenuItem(
                        value: CalendarView.week,
                        child: Text('Week'),
                      ),
                      PopupMenuItem(
                        value: CalendarView.schedule,
                        child: Text('Schedule'),
                      ),
                      PopupMenuItem(
                        value: CalendarView.timelineWeek,
                        child: Text('Timeline Week'),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              key: UniqueKey(),
              view: calendarView,
              dataSource: MeetingDataSource(_getDataSource()),
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> parseTimeString(String timeString) {
    List<String> timeParts = timeString.split(":");
    if (timeParts.length == 3) {
      int hour = int.tryParse(timeParts[0]) ?? 0;
      int minute = int.tryParse(timeParts[1]) ?? 0;
      int second = int.tryParse(timeParts[2]) ?? 0;

      return {'hour': hour, 'minute': minute, 'second': second};
    } else {
      throw FormatException("Invalid time format");
    }
  }
  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    //print(dataFromAPI[0].day.toString()) ;
    if (_tasks != null) {
      print("tasks!=null");
      for (Task task in _tasks) {
        print(task.summarize);
        int monthTask = int.parse(task.month);
        int dayTask = int.parse(task.day);
        Map<String, int> timeComponents = parseTimeString(task.specific_time);
        int? hourTask = timeComponents['hour'];
        int? minuteTask = timeComponents['minute'];
        int exHour = int.parse(task.expected_minute) ~/ 60;
        int exMinutes = int.parse(task.expected_minute) % 60;
        final DateTime today = DateTime.now();
        final DateTime startTime = DateTime(today.year, monthTask, dayTask,hourTask!, minuteTask!);
        final DateTime endTime = startTime.add( Duration(hours: exHour, minutes: exMinutes));
        meetings.add(Meeting(
            task.summarize, startTime, endTime,  getRandomColor(), false));
      }
    } else {
      print('Dữ liệu chưa được tải.');
    }

    return meetings;
  }
  Color getRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);

    return Color.fromRGBO(r, g, b, 1.0);
  }
}


class MeetingDataSource extends CalendarDataSource {

  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
}

String selectedOption = 'a'; // Giá trị mặc định
