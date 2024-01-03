
import 'dart:convert';import 'package:intl/intl.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

import '../Model/Data.dart';
import '../Model/Task.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import '../Service/notifi_service.dart';
import '../favor/newForm.dart';

Task objectTask  =   Task(
    summarize: "",
    specific_time: "",
    time_of_the_day: "",
    frequency: "",
    category: "",
    important: "",
    expected_minute: "",
    day_of_week: "",
    day: "",
    month: "",
    number_of_date: "",
    number_of_week: "",
    number_of_month: "",
    daily: "",
    weekly: "");


Future<void> main() async {


  runApp(const MyApp());
}

Future<Data> AddData(Data data) async {
  String urlPath ="192.168.0.188:8081";
  String callPath = "/api/v1/data";
  Data objectData =data;
  final response = await http.post(
    Uri.http(urlPath, callPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
    jsonEncode(<String, String>{
      'input':objectData.input,
      'output':objectData.output,
    }),
  );

  if (response.statusCode == 200) {
    print("code = 200 add data");
    return Data.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {

    throw Exception('Failed to create data.');
  }
}
String convertDateTimeFormat(String inputDateTime) {
  // Parse chuỗi đầu vào thành một đối tượng DateTime
  DateTime parsedDateTime = DateTime.parse(inputDateTime);

  // Định dạng lại đối tượng DateTime thành chuỗi theo định dạng "HH:mm:ss"
  String formattedTime = "${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}:${parsedDateTime.second.toString().padLeft(2, '0')}";

  return formattedTime;
}

Future<Task> AddTask(Task task) async {
  String urlPath ="192.168.0.188:8081";
  String callPath = "/api/v1/task";
  print("new");
  Task objectTask =task;
// Convert the Task object to a Map

// Convert the Map to a JSON string

  final response = await http.post(
    Uri.http(urlPath, callPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body:
    jsonEncode(<String, String>{
      'sumarize':objectTask.summarize,
      'specific_time':objectTask.specific_time,
      'time_of_the_day':objectTask.time_of_the_day,
      'frequency':objectTask.frequency,
      'category':objectTask.category,
      'important':objectTask.important,
      "expected_minute":objectTask.expected_minute,
      'day_of_week':objectTask.day_of_week,
      "day":objectTask.day,
      "month":objectTask.month,
      'number_of_date':objectTask.number_of_date,
      "number_of_week":objectTask.number_of_week,
      'number_of_month':objectTask.number_of_month,
      "daily":objectTask.daily,
      "weekly":objectTask.weekly,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    //developer.log('log me 2', name: 'my.other.category');
    print("code = 200 add task");
    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create task.');
  }
}


Future<Task> createTask(String content) async {
  print("entry createtask");
  String urlPath ="192.168.0.188:5000";
  String callPath = "predict";
 // content = 'I want to go cooking at 3 o clock this afternoon';
  final response = await http.post(
    Uri.http(urlPath, callPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      "entry": content,    }),
  );
  print(content);
  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    //developer.log('log me 2', name: 'my.other.category');
    print("code = 200 create task");


    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);

  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create task.');
  }
}




class Voice extends StatefulWidget {

  Voice({Key? key}) : super(key: key);

  @override
  _VoiceState createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {
  bool _isLoading = false;



  final TextEditingController _controller = TextEditingController();
  Future<Task>? _futureAlbum;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';




  @override
  void initState() {

    super.initState();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  String generateIdFromTime() {
    // Lấy thời gian hiện tại (milliseconds since epoch)
    int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

    // Chuyển đổi thời gian thành chuỗi và thêm một uuid ngẫu nhiên để đảm bảo sự duy nhất
    String id = '$currentTimeMillis-${Uuid().v4()}';

    return id;
  }
  /// Each time to start a speech recognition session
  void _startListening() async {
    print("init state");
    NotificationService().showNotification(title: 'Sample title', body: 'It works!');

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    print("init state");
    NotificationService().showNotification(title: 'Sample title', body: 'It works!');

    setState(() {
      _isLoading = true; // Bắt đầu loading
    });
    await _speechToText.stop();
    print(_lastWords);
    objectTask = await createTask(_lastWords);
    String output = "summarize: " + objectTask.summarize+ "\n"+ "time_of_the_day: "+ objectTask.time_of_the_day + "\n"+ "specific_time: " + objectTask.specific_time + "\n"+ "priority: " +
        objectTask.important + "\n"+ "frequency: " + objectTask.frequency + "\n"+ "category: " +objectTask.category + "\n"+ "important: "+objectTask.important+ "\n"+"expected_minute: "+objectTask.expected_minute+ "\n"+ "day_of_week: " +objectTask.day_of_week+ "\n"+ "day: "
    + objectTask.day+ "\n"+"month: "+objectTask.month+ "\n"+ "number_of_date: "+objectTask.number_of_date+ "\n"+  "number_of_month: "+objectTask.number_of_month+ "\n"+"daily: "+objectTask.daily+ "\n"+ "weekly"+ objectTask.weekly+ "\n" ;
    Data data = Data(id: generateIdFromTime(),input: _lastWords,output: output);
    print("stop listening");
    // AddData(data);
    setState(() {
      _isLoading = false; // Kết thúc loading
    });
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditForm(task: objectTask)),
    );
  }


  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords ;

    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/giphy.gif', width: 280, height: 280, fit: BoxFit.cover),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Recognized words:',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _isLoading
                          ? 'Loading...' // Hiển thị khi đang lắng nghe
                          : _speechToText.isListening
                          ? '$_lastWords'
                          : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 80, // Adjust the distance from the bottom
              child: FloatingActionButton(
                onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                tooltip: 'Listen',
                child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                backgroundColor: Theme.of(context).primaryColor, // Set background color to green
                foregroundColor: Colors.white, // Set foreground color (icon color) to white
                heroTag: null, // Remove the hero tag to prevent a tag conflict warning
              ),
            ),
          ],
        ),
      ),
    );
  }




}





class EditForm extends StatefulWidget {

  late Task task;

  // Thêm constructor để nhận dữ liệu từ Voice
  EditForm({required this.task});


  @override
  _EditFormState createState() => _EditFormState();
}
Time parseTimeStringToTime(String inputTimeString) {
  List<String> timeParts = inputTimeString.split(':');

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  int second = int.parse(timeParts[2]);

  return Time(hour:hour, minute:minute, second:second);
}
class _EditFormState extends State<EditForm> {
  Time _time =  parseTimeStringToTime(objectTask.specific_time);
  static DateTime startDate = DateTime.now();
  String quoteStartDate =
  DateFormat.yMMMd().format(startDate.add(Duration(days: 1))).toString();
  String endPeriod = DateFormat.yMMMd()
      .format(DateTime.now().add(Duration(days: 30)))
      .toString();

  //Time(hour: 11, minute: 30, second: 20);
  bool iosStyle = true;
  TextEditingController summarizeController = TextEditingController();
  TextEditingController sessionController = TextEditingController();
  TextEditingController frequenceController = TextEditingController();
  TextEditingController categoryInputController = TextEditingController();
  TextEditingController expectedTimeController = TextEditingController();
  TextEditingController prorityController = TextEditingController();

  TextEditingController timeInputController = TextEditingController();
  String selectedFrequence = 'Single'; // Initial value for the dropdown
  bool rememberMe = false; // Initial value for the Remember Me field
  TextEditingController dateinput = TextEditingController();
  TextEditingController dateInputController = TextEditingController(); // Thêm controller cho date picker

  void onTimeChanged(Time newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    timeInputController.text = ""; //set the initial value of text field
    dateinput.text = ""; //set the initial value of text field
    summarizeController.text = widget.task.summarize;
    sessionController.text = widget.task.time_of_the_day;
    frequenceController.text = widget.task.frequency;
    expectedTimeController.text = widget.task.expected_minute  +  " minutes";
    timeInputController.text = widget.task.specific_time;
    prorityController.text =  widget.task.important+"/ 5";
    dateInputController.text =
        DateTime.now().year.toString() + "/" + widget.task.month + "/" + widget.task.day;
    categoryInputController.text = widget.task.category;
    super.initState();
  }


  // Widget cho date picker
  Widget _buildDatePicker(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: dateInputController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_today),
            labelText: "Date",
          ),
          onTap: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (selectedDate != null) {
              dateInputController.text = selectedDate.toLocal().toString().split(' ')[0];
            }
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  void _openTimePicker(BuildContext context) {
    Navigator.of(context).push(
      showPicker(
        showSecondSelector: true,
        context: context,
        value: _time,
        onChange: onTimeChanged,
        minuteInterval: TimePickerInterval.FIVE,
        onChangeDateTime: (DateTime dateTime) {
          timeInputController.text = convertDateTimeFormat(dateTime.toString());
          debugPrint("[debug datetime]: $dateTime");
        },
      ),
    );
  }
  String convertDateTimeFormat(String inputDateTime) {
    // Chuyển chuỗi thời gian sang đối tượng DateTime
    DateTime dateTime = DateTime.parse(inputDateTime);

    // Chuyển đối tượng DateTime sang chuỗi theo định dạng mong muốn
    String formattedTime = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

    return formattedTime;
  }
  Widget _buildTimePickerTextField(BuildContext context) {
    return Column(
      children: [
        TextField(
          readOnly: true,
          onTap: () {
            _openTimePicker(context);
          },
          controller: TextEditingController(text: _time.format(context)),
          decoration: InputDecoration(
            labelText: 'Time',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.access_time),
            contentPadding: const EdgeInsets.all(16),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }



  Widget _buildText(String labelText, String textValue, {required MaterialColor color, required double fontSize, required FontWeight fontWeight}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0), // Khoảng trống dưới
          child: Text(
            labelText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // Khoảng trống dưới
          child: Text(
            textValue,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


  Color mediumPurpleColor = Color(0xFF9370DB);
  @override
  Widget build(BuildContext context) {
   // _time = parseTimeStringToTime(widget.task.specific_time);


    return Scaffold(
      appBar: AppBar(
        title: Text('Task'), // Tiêu đề của AppBar
        backgroundColor: mediumPurpleColor, // Màu nền của AppBar
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 0),
            _buildHighlightedPanel(
              child: _buildText(
                'Task has been generated',
                'Edit if our assistant transfers it incorrectly',
                color: Colors.grey,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: mediumPurpleColor, // Choose your color
            ),
            SizedBox(height: 10),
            _buildTextField('Summary', summarizeController, Icons.short_text),
            SizedBox(height: 10),
            _buildTextField('Period of the day',  sessionController, Icons.wb_sunny),
            SizedBox(height: 10),
            _buildTimePickerTextField(context),
            SizedBox(height: 10),
            _buildTextNumberField('Duration', expectedTimeController, Icons.timelapse),
            SizedBox(height: 10),
            // _buildFrequenceDropdown(),
            // SizedBox(height: 10),
            _buildDatePicker(context),
            SizedBox(height: 10),
            _buildTextField('Priority',  prorityController, Icons.wb_sunny),
            SizedBox(height: 10),
            _buildTextField('Category', categoryInputController, Icons.category),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate back to the previous screen
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text(
                    'Back',

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confirm to add task'),
                      content: const Text('Do you want to add this task to your calendar?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? datetime = parseDateString(dateInputController.text);
                            Task myTask = Task(
                              frequency: frequenceController.text,
                              summarize: summarizeController.text,
                              time_of_the_day: sessionController.text,
                              specific_time:  _time.format(context)+ ":00",
                              important: prorityController.text .replaceRange(prorityController.text .length - 3, prorityController.text .length, ""),
                              category: categoryInputController.text,
                              expected_minute:   expectedTimeController.text .replaceRange(expectedTimeController.text .length - 8, expectedTimeController.text .length, ""),
                              day_of_week: widget.task.day_of_week,
                              day: datetime!.day.toString(),
                              month: datetime.month.toString(),
                              number_of_date: widget.task.number_of_date,
                              number_of_week: widget.task.number_of_week,
                              //number_of_month: widget.task.number_of_month,
                              number_of_month: "false",
                              weekly: widget.task.weekly,
                              daily: widget.task.daily,
                            );
                            AddTask(myTask);
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  icon: Icon(Icons.check),
                  label: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(mediumPurpleColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );


  }

  Widget _buildHighlightedPanel(
      {required Widget child, required Color backgroundColor}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      margin: EdgeInsets.all(0.0),
      width: screenWidth,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: child,
    );
  }

  DateTime? parseDateString(String dateString) {
    try {
      List<String> dateParts = dateString.split('/');
      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      // Xử lý nếu có lỗi khi chuyển đổi
      print("Error parsing date string: $e");
      return null;
    }
  }


  Widget _buildTextNumberField(String labelText, TextEditingController controller, IconData prefixIcon) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
            prefixIcon: Icon(prefixIcon),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, IconData prefixIcon) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
            prefixIcon: Icon(prefixIcon),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeInputField(DateTime time) {
    return Column(
      children: [
        TextField(
          controller: timeInputController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
            labelText: "Time",
          ),
          readOnly: true,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            print(pickedTime?.format(context));
            timeInputController.text = convertTime12to24(pickedTime!.format(context).toString())  ;
          },
        ),

      ],
    );
  }


  String convertTime12to24(String time12h) {
    final dateFormat = DateFormat("h:mm a");
    final time12 = dateFormat.parse(time12h);

    final time24Format = DateFormat("HH:mm:ss");
    final time24 = time24Format.format(time12);

    return time24;
  }
  Widget _buildFrequenceDropdown() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          margin: EdgeInsets.only(bottom: 16.0), // Adjust margin for consistency
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule),
              SizedBox(width: 8.0),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedFrequence,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFrequence = newValue!;
                    });
                  },
                  items: ['Single', 'Loop'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Frequence',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: rememberMe,
          onChanged: (bool? newValue) {
            setState(() {
              rememberMe = newValue ?? false;
            });
          },
        ),
        Text('Remember Me'),
      ],
    );
  }
}



