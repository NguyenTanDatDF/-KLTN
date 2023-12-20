class Task {
  final int id;
  final String sum;
  final String totd;
  final String spec_time;
  final String prio;
  final String status;
  final String cate;
  final String diff;
  final String imp;
  final String exp_min;
  final String dow;
  final String day;
  final String month;
  final String no_date;
  final String no_week;
  final String no_month;
  const Task({
    required this.id,
    required  this.sum,
    required  this.totd,
    required  this.spec_time,
    required   this.prio,
    required   this.status,
    required  this.cate,
    required  this.diff,
    required  this.imp,
    required  this.exp_min,
    required  this.dow,
    required  this.day,
    required  this.month,
    required  this.no_date,
    required  this.no_week,
    required  this.no_month
  });


  factory Task.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {

    'id': int id,
     'sum' : String sum,
    'totd' : String totd,
    'spec_time' : String spec_time,
    'prio' : String prio,
    'status' :  String status,
    'cate' :  String cate,
    'diff' : String diff,
    'imp' : String imp,
    'exp_min' : String exp_min,
    'dow' :  String dow,
    'day' : String day,
    'month' :  String month,
    'no_date' : String no_date,
    'no_week' : String no_week,
    'no_month' :  String no_month,

    } =>
    Task(
    id: id,
    sum :  sum,
    totd :  totd,
    spec_time :  spec_time,
    prio :  prio,
    status :   status,
    cate :   cate,
    diff :  diff,
    imp :  imp,
    exp_min :  exp_min,
    dow :   dow,
    day :  day,
    month :   month,
    no_date :  no_date,
    no_week :  no_week,
    no_month :   no_month,
    ),
    _ => throw const FormatException('Failed to load task.'),
  };
  }
}