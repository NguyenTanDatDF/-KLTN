class Task {
  final String summarize;
  final String time_of_the_day;
  final String specific_time;
  final String frequency;
  final String important;
  final String category;
  final String expected_minute;
  final String day_of_week;
  final String day;
  final String month;
  final String number_of_date;
  final String number_of_week;
  final String number_of_month;
  final String weekly;
  final String daily;
  const Task({
    required  this.summarize,
    required  this.time_of_the_day,
    required  this.specific_time,
    required  this.frequency,
    required   this.important,
    required  this.category,
    required  this.expected_minute,
    required  this.day_of_week,
    required  this.day,
    required  this.month,
    required  this.number_of_date,
    required  this.number_of_week,
    required  this.number_of_month,
    required this.daily,
    required this.weekly,
  });


  factory Task.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      "frequency": String frequency,
     'summarize' : String summarize,
    'time_of_the_day' : String time_of_the_day,
    'specific_time' : String specific_time,
    'important' : String important,
    'category' :  String category,
    'expected_minute' : String expected_minute,
    'day_of_week' :  String day_of_week,
    'day' : String day,
    'month' :  String month,
    'number_of_date' : String number_of_date,
    'number_of_week' : String number_of_week,
    'number_of_month' :  String number_of_month,
    'weekly' : String weekly,
    'daily' :String daily
    
    } =>
    Task(
    frequency : frequency,
    summarize :  summarize,
    time_of_the_day :  time_of_the_day,
    specific_time :  specific_time,
    important :  important,
    category :   category,
    expected_minute :  expected_minute,
    day_of_week :   day_of_week,
    day :  day,
    month :   month,
    number_of_date :  number_of_date,
    number_of_week :  number_of_week,
    number_of_month :   number_of_month,
    weekly :  weekly,
    daily : daily
    ),
    _ => throw const FormatException('Failed to load task.'),
  };
  }
}