import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';

import '../Model/Task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Always initialize Awesome Notifications
  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();
  runApp(const ProfileScreen());
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


///  *********************************************
///     NOTIFICATION CONTROLLER
///  *********************************************
///
class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'alerts',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    ProfileScreen.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
            (route) =>
        (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///
  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = ProfileScreen.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************
  ///

  static Future<void> executeLongListTaskInBackground(List<Task> listTask) async {
    print("starting long list task");

    await Future.delayed(const Duration(seconds: 10));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);

    print("long task done");
    NotificationController.createNewNotification();

  }


  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 10));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);

    print("long task done");
    NotificationController.createNewNotification();

  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  static int generateRandomNumberFromInputString(String inputString) {
    // Sử dụng hàm hashCode để chuyển đổi chuỗi thành số nguyên
    int hashedValue = inputString.hashCode;

    // Sử dụng giá trị hash làm cơ sở để sinh số ngẫu nhiên
    Random random = Random(hashedValue);
    int randomNumber = random.nextInt(100); // Số ngẫu nhiên từ 0 đến 99

    return randomNumber;
  }
  static List<int> parseTimeString(String timeString) {
    List<String> timeComponents = timeString.split(':');
    List<int> parsedTime = [];

    for (String component in timeComponents) {
      parsedTime.add(int.parse(component));
    }

    return parsedTime;
  }

  static Future<void> createNewListSchedule(List<Task> tasks) async {
    // bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    // if (!isAllowed) isAllowed = await displayNotificationRationale();
    // if (!isAllowed) return;
    //
    // for(Task task in tasks)
    //   {
    //     List<int> hms = parseTimeString(task.specific_time);
    //      print(task.specific_time);
    //      int id = generateRandomNumberFromInputString(task.summarize+task.specific_time);
    //     print("hms: " + hms[0].toString());
    //      await AwesomeNotifications().createNotification(
    //        schedule: NotificationCalendar(
    //            hour: 17,
    //            minute: 7,
    //            second: 0,
    //            repeats: true
    //        ),
    //          content: NotificationContent(
    //              id:id, // -1 is replaced by a random number
    //              channelKey: 'alerts',
    //              title: "You have a task!",
    //              body:
    //              task.summarize,
    //              bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
    //              largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
    //              //'asset://assets/images/balloons-in-sky.jpg',
    //              notificationLayout: NotificationLayout.BigPicture,
    //              payload: {'notificationId': '1234567890'}),
    //          actionButtons: [
    //            NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
    //            NotificationActionButton(
    //                key: 'REPLY',
    //                label: 'Reply Message',
    //                requireInputText: true,
    //                actionType: ActionType.SilentAction),
    //            NotificationActionButton(
    //                key: 'DISMISS',
    //                label: 'Dismiss',
    //                actionType: ActionType.DismissAction,
    //                isDangerousOption: true)
    //          ]);
    //   }


     for(Task task in tasks)
       {
         print("Task schedule at hms: " + task.specific_time);
         createNewNotificationWithAgrs(task);

       }
  }

  static Future<void> createNewNotificationWithAgrs(Task task) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;
    List<int> hms = parseTimeString(task.specific_time);
    print(hms[0]);
    print(hms[1]);
    print(hms[2]);
    int id = generateRandomNumberFromInputString(task.summarize+task.specific_time);
    await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar(
            hour: hms[0],
            minute: hms[1],
            second: hms[2],
            repeats: true
        ),
        content: NotificationContent(
            id:id, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Hello boss, you have an upcoming task!',
            body:
            task.summarize,
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          // NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          // NotificationActionButton(
          //     key: 'REPLY',
          //     label: 'Reply Message',
          //     requireInputText: true,
          //     actionType: ActionType.SilentAction,
          // ),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }


  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        schedule: NotificationCalendar(
            hour: 12,
            minute: 35,
            second: 00,
            repeats: true
        ),
        content: NotificationContent(
            id:1, // -1 is replaced by a random number
            channelKey: 'alerts',
            title: 'Huston! The eagle has landed!',
            body:
            "A small step for a man, but a giant leap to Flutter's community!",
            bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            payload: {'notificationId': '1234567890'}),
        actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction),
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static Future<void> scheduleNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await myNotifyScheduleInHours(
        title: 'test',
        msg: 'test message',
        heroThumbUrl:
        'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
        hoursFromNow:  5,
        username: 'test user',
        repeatNotif: false);
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

Future<void> myNotifyScheduleInHours({
  required int hoursFromNow,
  required String heroThumbUrl,
  required String username,
  required String title,
  required String msg,
  bool repeatNotif = false,
}) async {
  var nowDate = DateTime.now().add(Duration(hours: hoursFromNow, seconds: 5));
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      //weekday: nowDate.day,
      hour: nowDate.hour,
      minute: 0,
      second: nowDate.second,
      repeats: repeatNotif,
      //allowWhileIdle: true,
    ),
    // schedule: NotificationCalendar.fromDate(
    //    date: DateTime.now().add(const Duration(seconds: 10))),
    content: NotificationContent(
      id: -1,
      channelKey: 'basic_channel',
      title: '${Emojis.food_bowl_with_spoon} $title',
      body: '$username, $msg',
      bigPicture: heroThumbUrl,
      notificationLayout: NotificationLayout.BigPicture,
      //actionType : ActionType.DismissAction,
      color: Colors.black,
      backgroundColor: Colors.black,
      // customSound: 'resource://raw/notif',
      payload: {'actPag': 'myAct', 'actType': 'food', 'username': username},
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'NOW',
        label: 'btnAct1',
      ),
      NotificationActionButton(
        key: 'LATER',
        label: 'btnAct2',
      ),
    ],
  );
}

///  *********************************************
///     MAIN WIDGET
///  *********************************************
///
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  // The navigator key is necessary to navigate using static methods
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Color mainColor = const Color(0xFF9D50DD);

  @override
  State<ProfileScreen> createState() => _AppState();
}

class _AppState extends State<ProfileScreen> {
  // This widget is the root of your application.

  static const String routeHome = '/', routeNotification = '/notification-page';

  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];
    pageStack.add(MaterialPageRoute(
        builder: (_) =>
        const MyHomePage(title: 'Awesome Notifications Example App')));
    if (initialRouteName == routeNotification &&
        NotificationController.initialAction != null) {
      pageStack.add(MaterialPageRoute(
          builder: (_) => NotificationPage(
              receivedAction: NotificationController.initialAction!)));
    }
    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHome:
        return MaterialPageRoute(
            builder: (_) =>
            const MyHomePage(title: 'Awesome Notifications Example App'));

      case routeNotification:
        ReceivedAction receivedAction = settings.arguments as ReceivedAction;
        return MaterialPageRoute(
            builder: (_) => NotificationPage(receivedAction: receivedAction));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Notifications - Simple Example',
      navigatorKey: ProfileScreen.navigatorKey,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

///  *********************************************
///     HOME PAGE
///  *********************************************
///
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Push the buttons below to create new notifications',
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20),
            FloatingActionButton(
              heroTag: '1',
              onPressed: () => NotificationController.createNewListSchedule(_tasksraw),
              tooltip: 'Create New notification',
              child: const Icon(Icons.outgoing_mail),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: '2',
              onPressed: () => NotificationController.createNewNotification(),
              tooltip: 'Schedule New notification',
              child: const Icon(Icons.access_time_outlined),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: '3',
              onPressed: () => {
                NotificationController.executeLongTaskInBackground(),

              },

              tooltip: 'Reset badge counter',
              child: const Icon(Icons.exposure_zero),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: '4',
              onPressed: () => NotificationController.cancelNotifications(),
              tooltip: 'Cancel all notifications',
              child: const Icon(Icons.delete_forever),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

///  *********************************************
///     NOTIFICATION PAGE
///  *********************************************
class NotificationPage extends StatefulWidget {
  const NotificationPage({
    Key? key,
    required this.receivedAction,
  }) : super(key: key);

  final ReceivedAction receivedAction;

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {



  bool get hasTitle => widget.receivedAction.title?.isNotEmpty ?? false;
  bool get hasBody => widget.receivedAction.body?.isNotEmpty ?? false;
  bool get hasLargeIcon => widget.receivedAction.largeIconImage != null;
  bool get hasBigPicture => widget.receivedAction.bigPictureImage != null;

  double bigPictureSize = 0.0;
  double largeIconSize = 0.0;
  bool isTotallyCollapsed = false;
  bool bigPictureIsPredominantlyWhite = true;

  ScrollController scrollController = ScrollController();

  Future<bool> isImagePredominantlyWhite(ImageProvider imageProvider) async {
    final paletteGenerator =
    await PaletteGenerator.fromImageProvider(imageProvider);
    final dominantColor =
        paletteGenerator.dominantColor?.color ?? Colors.transparent;
    return dominantColor.computeLuminance() > 0.5;
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_scrollListener);
    if (hasBigPicture) {
      isImagePredominantlyWhite(widget.receivedAction.bigPictureImage!)
          .then((isPredominantlyWhite) => setState(() {
        bigPictureIsPredominantlyWhite = isPredominantlyWhite;
      }));
    }
  }

  void _scrollListener() {
    bool pastScrollLimit = scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 240;

    if (!hasBigPicture) {
      isTotallyCollapsed = true;
      return;
    }

    if (isTotallyCollapsed) {
      if (!pastScrollLimit) {
        setState(() {
          isTotallyCollapsed = false;
        });
      }
    } else {
      if (pastScrollLimit) {
        setState(() {
          isTotallyCollapsed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bigPictureSize = MediaQuery.of(context).size.height * .4;
    largeIconSize =
        MediaQuery.of(context).size.height * (hasBigPicture ? .16 : .2);

    if (!hasBigPicture) {
      isTotallyCollapsed = true;
    }

    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isTotallyCollapsed || bigPictureIsPredominantlyWhite
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            systemOverlayStyle:
            isTotallyCollapsed || bigPictureIsPredominantlyWhite
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
            expandedHeight: hasBigPicture
                ? bigPictureSize + (hasLargeIcon ? 40 : 0)
                : (hasLargeIcon)
                ? largeIconSize + 10
                : MediaQuery.of(context).padding.top + 28,
            backgroundColor: Colors.transparent,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              centerTitle: true,
              expandedTitleScale: 1,
              collapseMode: CollapseMode.pin,
              title: (!hasLargeIcon)
                  ? null
                  : Stack(children: [
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: hasBigPicture
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: largeIconSize,
                        width: largeIconSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(largeIconSize)),
                          child: FadeInImage(
                            placeholder: const NetworkImage(
                                'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                            image: widget.receivedAction.largeIconImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              background: hasBigPicture
                  ? Padding(
                padding: EdgeInsets.only(bottom: hasLargeIcon ? 60 : 20),
                child: FadeInImage(
                  placeholder: const NetworkImage(
                      'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
                  height: bigPictureSize,
                  width: MediaQuery.of(context).size.width,
                  image: widget.receivedAction.bigPictureImage!,
                  fit: BoxFit.cover,
                ),
              )
                  : null,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          if (hasTitle)
                            TextSpan(
                              text: widget.receivedAction.title!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          if (hasBody)
                            WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: hasTitle ? 16.0 : 0.0,
                                ),
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(
                                        widget.receivedAction.bodyWithoutHtml ??
                                            '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2)),
                              ),
                            ),
                        ]),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black12,
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  child: Text(widget.receivedAction.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}