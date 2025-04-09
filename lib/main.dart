// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  runApp(const MyApp());
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  print("📩 Background message received!");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Custom Data: ${message.data}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token = "Fetching token...";
  String _customData = "No custom data";
  List<String> _notificationHistory = [];

  @override
  void initState() {
    super.initState();
    getToken();
    loadNotificationHistory();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground message received!");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");

      setState(() {
        _customData = message.data.toString();
      });

      String notification = "Title: ${message.notification?.title}, Body: ${message.notification?.body}";
      storeNotificationHistory(notification);

      String notificationType = message.data['type'] ?? 'regular'; 
      Color backgroundColor = notificationType == 'important' ? Colors.red : Colors.green;

      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(message.notification!.title ?? "Notification"),
            content: Text(message.notification!.body ?? ""),
            backgroundColor: backgroundColor,
            actions: [
              TextButton(
                onPressed: () {
                  print("Action 1 clicked");
                  Navigator.of(context).pop();
                },
                child: const Text("Action 1"),
              ),
              TextButton(
                onPressed: () {
                  print("Action 2 clicked");
                  Navigator.of(context).pop();
                },
                child: const Text("Action 2"),
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📩 Tapped on notification");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");

      setState(() {
        _customData = message.data.toString();
      });

      String notification = "Title: ${message.notification?.title}, Body: ${message.notification?.body}";
      storeNotificationHistory(notification);

      String notificationType = message.data['type'] ?? 'regular'; 
      Color backgroundColor = notificationType == 'important' ? Colors.red : Colors.green;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message.notification!.title ?? "Notification"),
          content: Text(message.notification!.body ?? ""),
          backgroundColor: backgroundColor, 
          actions: [
            TextButton(
              onPressed: () {
                print("Action 1 clicked");
                Navigator.of(context).pop();
              },
              child: const Text("Action 1"),
            ),
            TextButton(
              onPressed: () {
                print("Action 2 clicked");
                Navigator.of(context).pop();
              },
              child: const Text("Action 2"),
            ),
          ],
        ),
      );
    });
  }

  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    setState(() {
      _token = token;
    });
  }

  Future<void> storeNotificationHistory(String notification) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentHistory = prefs.getStringList('notificationHistory') ?? [];
    currentHistory.add(notification);
    await prefs.setStringList('notificationHistory', currentHistory);
    setState(() {
      _notificationHistory = currentHistory;
    });
  }

  Future<void> loadNotificationHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('notificationHistory') ?? [];
    setState(() {
      _notificationHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Token")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText("FCM Token: $_token"),
            const SizedBox(height: 16),
            Text("Custom Data: $_customData"),
            const SizedBox(height: 16),
            const Text("Notification History:"),
            Expanded(
              child: ListView.builder(
                itemCount: _notificationHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_notificationHistory[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
