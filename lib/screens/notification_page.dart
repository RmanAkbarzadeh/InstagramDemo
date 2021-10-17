import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/notification.dart';
import 'package:instagram_demo/notification/notification_item.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);
  static const String routeName = "/notif-page";

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppNotifications>(context, listen: false)
        .getNotifications();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureItems = Provider.of<AppNotifications>(context, listen: false)
                .getNotifications();
          });
        },
        child: FutureBuilder(
          future: futureItems,
          builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(snapshot.data!.docs.length !=0) {
              final document = snapshot.data!.docs;
              return ListView.builder(itemBuilder: (context, index) {
                return NotificationItem(document[index]["anotherUserId"],
                    document[index]["username"],
                    document[index]["description"],
                    document[index]["imageUrl"]
                );
              }, itemCount: document.length,);
            }else{
              return Center(child: Text("You have not any activity !",style: TextStyle(fontSize: 22),),);
            }
          }
        ),
      ),
    );
  }
}
