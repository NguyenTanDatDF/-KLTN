import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:todo_kltn/Service/SwipeDetector.dart';
import '../Model/Task.dart';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


Future<Task> createTask(String content) async {
  String urlPath ="localhost:8081";
  String callPath = "/api/v1/task";
  final response = await http.post(
    Uri.http(urlPath, callPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'sumarize':"tanning 11 10 AM "
      ,'specific_time':"morning",
      'time_of_the_day':"11:00:00",
      'frequency':"single",
      'category':"travelling",
      'important':"3","expected_minute":"30 ",
      'day_of_week':"","day":"10","month":"12",
      'number_of_date':"3","number_of_week":"",
      'number_of_month':"","daily":"","weekly":""
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    //developer.log('log me 2', name: 'my.other.category');
    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}




class Voice extends StatefulWidget {
  Voice({Key? key}) : super(key: key);

  @override
  _VoiceState createState() => _VoiceState();
}

class _VoiceState extends State<Voice> {


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

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _futureAlbum = createTask(_lastWords);
      print("stop listening");
    });

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
      appBar: AppBar(

      ),
      body: Center(





        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                  // If listening is active show the recognized words
                  _speechToText.isListening
                      ? '$_lastWords'
                  // If listening isn't active but could be tell the user
                  // how to start it, otherwise indicate that speech
                  // recognition is not yet ready or not supported on
                  // the target device
                      : _speechEnabled
                      ? 'Tap the microphone to start listening...'
                      : 'Speech not available',
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed:
        // If not yet listening for speech start, otherwise stop
        _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}