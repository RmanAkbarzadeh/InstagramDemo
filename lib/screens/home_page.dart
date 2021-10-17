import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_screen.dart';
import 'package:instagram_demo/models/notification_handler.dart';
import 'package:instagram_demo/res/images.dart';
import 'package:instagram_demo/screens/notification_page.dart';
import 'package:instagram_demo/screens/profile_page.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'adding_post_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = "/home-page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavigationIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  final user = FirebaseAuth.instance.currentUser;
  bool isShown = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("I AM HERE");
      NotificationHandler.showNotification(
          1234,
          event.notification!.title as String,
          event.notification!.body as String,
          event.data["screen"],
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin);
    });
  }

  Future<dynamic> onSelectNotification(String? routeName) async {
    Navigator.of(context).pushNamed(routeName as String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _bottomNavigationIndex == 0
          ? AppBar(
              title: Image.asset(
                InstagramImages.instagram_text_logo,
                width: 100,
                height: 30,
                fit: BoxFit.fill,
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(DirectScreen.routeName);
                    },
                    icon: Icon(Icons.send))
              ],
            )
          : null,
      body: PageView(
        controller: _pageController,
        onPageChanged: (newIndex) {
          setState(() {
            _bottomNavigationIndex = newIndex;
          });
        },
        children: [
          PostsList(PostFrom.Home, user!.uid),
          SearchPage(),
          AddingPostPage(),
          NotificationPage(),
          ProfilePage(isPageView: true)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavigationIndex,
        onTap: (index) {
          setState(() {
            _pageController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 30), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30), label: ""),
        ],
      ),
    );
  }
}
