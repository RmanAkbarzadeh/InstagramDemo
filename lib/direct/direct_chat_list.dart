import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_list_item.dart';
import 'package:instagram_demo/models/direct.dart';
import 'package:provider/provider.dart';

class DirectChatList extends StatefulWidget {
  const DirectChatList({Key? key}) : super(key: key);
  static const String routeName = "/direct-chat-list";

  @override
  _DirectChatListState createState() => _DirectChatListState();
}

class _DirectChatListState extends State<DirectChatList> {


  Stream<DocumentSnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppDirects>(context,listen: false).getDirectList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          futureItems = Provider.of<AppDirects>(context,listen: false).getDirectList();
        });
      },
      child: StreamBuilder(
        stream: futureItems,
        builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if ((snapshot.data!["chatList"] as List<dynamic>).isNotEmpty) {
            final document = snapshot.data;
            var chatList = document!["chatList"] as List<dynamic>;
            chatList = chatList.reversed.toList();
            return ListView.builder(itemBuilder: (context, index) {
              return DirectChatListItem(chatList[index]);
            }, itemCount: chatList.length,);
          }else{
            return Center(child: Text("You can start talking with others !",style: TextStyle(fontSize: 22),),);
          }
        }
      ),
    );
  }
}
