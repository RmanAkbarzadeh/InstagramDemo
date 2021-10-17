import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_list.dart';
import 'package:instagram_demo/direct/direct_new_chat_screen.dart';
import 'package:instagram_demo/direct/direct_screen.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/models/direct.dart';
import 'package:instagram_demo/models/notification.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/models/story.dart';
import 'package:instagram_demo/profile/edit_profile_page.dart';
import 'package:instagram_demo/res/colors.dart';
import 'package:instagram_demo/adding_post/adding_post_detail.dart';
import 'package:instagram_demo/screens/adding_post_page.dart';
import 'package:instagram_demo/screens/comment_page.dart';
import 'package:instagram_demo/screens/home_page.dart';
import 'package:instagram_demo/screens/login_page.dart';
import 'package:instagram_demo/screens/notification_page.dart';
import 'package:instagram_demo/screens/profile_page.dart';
import 'package:instagram_demo/screens/search_page.dart';
import 'package:instagram_demo/story/add_new_story_screen.dart';
import 'package:instagram_demo/story/adding_story_detail.dart';
import 'package:instagram_demo/story/adding_story_users_input.dart';
import 'package:provider/provider.dart';

import 'models/user.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppUsers()),
        ChangeNotifierProvider(create: (context) => AppPosts()),
        ChangeNotifierProvider(create: (context) => AppStories()),
        ChangeNotifierProvider(create: (context) => AppDirects()),
        ChangeNotifierProvider(create: (context) => AppNotifications()),
      ],
      child: MaterialApp(
        title: 'Instagram demo',
        theme: ThemeData(
            //brightness: Brightness.light,
            ),
        darkTheme: ThemeData(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: InstagramColor.backgroundColor,
          ),
            bottomNavigationBarTheme: Theme.of(context).bottomNavigationBarTheme.copyWith(
              backgroundColor: InstagramColor.backgroundColor,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white
            ),
            scaffoldBackgroundColor: InstagramColor.backgroundColor,
            brightness: Brightness.dark,
            textTheme: Theme.of(context).textTheme.apply(
                bodyColor: InstagramColor.textColor,
                displayColor: InstagramColor.textColor),
            backgroundColor: InstagramColor.backgroundColor),
        themeMode: ThemeMode.dark,

        debugShowCheckedModeBanner: false,

        home: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),builder:(context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasData){
            return HomePage();
          }
          else{
            return LoginPage();
          }
        }, ),
        routes: {
          HomePage.routeName : (ctx) => HomePage(),
          NotificationPage.routeName : (ctx) => NotificationPage(),
          AddingPostPage.routeName : (ctx) => AddingPostPage(),
          CommentPage.routeName : (ctx) => CommentPage(),
          SearchPage.routeName : (ctx) => SearchPage(),
          ProfilePage.routeName : (ctx) => ProfilePage(isPageView: false,),
          AddingPostDetail.routeName : (ctx) => AddingPostDetail(),
          PostsList.routeName : (ctx) => PostsList(PostFrom.Home,FirebaseAuth.instance.currentUser!.uid),
          EditProfilePage.routeName : (ctx) => EditProfilePage(),
          AddingStoryDetail.routeName : (ctx) => AddingStoryDetail(),
          AddNewStoryScreen.routeName : (ctx) => AddNewStoryScreen(),
          AddingStoryUseresInput.routeName : (ctx) => AddingStoryUseresInput(),
          DirectScreen.routeName : (ctx) => DirectScreen(),
          DirectNewChatScreen.routeName : (ctx) => DirectNewChatScreen(),
          DirectChatList.routeName : (ctx) => DirectChatList()
        },
      ),
    );
  }
}
