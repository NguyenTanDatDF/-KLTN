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
   bool get isCompleted => number_of_month.toLowerCase() == 'true';

  const Task( {
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

   factory Task.fromJson1(Map<String, dynamic> json) {
     return Task(
       frequency: json["frequency"] as String? ?? "",
       summarize: json["sumarize"] as String? ?? "",
       time_of_the_day: json["time_of_the_day"] as String? ?? "",
       specific_time: json["specific_time"] as String? ?? "",
       important: json["important"] as String? ?? "",
       category: json["category"] as String? ?? "",
       expected_minute: json["expected_minute"] as String? ?? "",
       day_of_week: json["day_of_week"] as String? ?? "",
       day: json["day"] as String? ?? "",
       month: json["month"] as String? ?? "",
       number_of_date: json["number_of_date"] as String? ?? "",
       number_of_week: json["number_of_week"] as String? ?? "",
       number_of_month: json["number_of_month"] as String? ?? "",
       weekly: json["weekly"] as String? ?? "",
       daily: json["daily"] as String? ?? "",
     );
   }
   Map<String, dynamic> toJson() {
     return {
       'summarize': summarize,
       'time_of_the_day': time_of_the_day,
       'specific_time': specific_time,
       'frequency': frequency,
       'important': important,
       'category': category,
       'expected_minute': expected_minute,
       'day_of_week': day_of_week,
       'day': day,
       'month': month,
       'number_of_date': number_of_date,
       'number_of_week': number_of_week,
       'number_of_month': number_of_month,
       'weekly': weekly,
       'daily': daily,
     };
   }
   factory Task.fromJson5(Map<String, dynamic> json) {
     return Task(
       summarize: json['summarize'],
       time_of_the_day: json['time_of_the_day'],
       specific_time: json['specific_time'],
       frequency: json['frequency'],
       important: json['important'],
       category: json['category'],
       expected_minute: json['expected_minute'],
       day_of_week: json['day_of_week'],
       day: json['day'],
       month: json['month'],
       number_of_date: json['number_of_date'],
       number_of_week: json['number_of_week'],
       number_of_month: json['number_of_month'],
       weekly: json['weekly'],
       daily: json['daily'],
     );
   }
   factory Task.fromMap(Map<String, dynamic> json) => Task(
       frequency : json["frequency"] as String,
       summarize :  json["summarize"] as String,
       time_of_the_day :  json["time_of_the_day"] as String,
       specific_time :  json["specific_time"] as String,
       important :  json["important"] as String,
       category :   json["category"] as String,
       expected_minute :  json["expected_minute"] as String,
       day_of_week :   json["day_of_week"] as String,
       day :  json["day"] as String,
       month :   json["month"] as String,
       number_of_date :  json["number_of_date"] as String,
       number_of_week :  json["number_of_week"] as String,
       number_of_month :   json["number_of_month"] as String,
       weekly :  json["weekly"] as String,
       daily : json["daily"] as String,
   );

  factory Task.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      "frequency": String frequency,
     "summarize" : String summarize,
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



  set year(String year) {}
}