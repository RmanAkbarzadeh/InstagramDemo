import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_load_useres.dart';

class DirectNewChatScreen extends StatelessWidget {
  const DirectNewChatScreen({Key? key}) : super(key: key);
  static const String routeName = "/direct-new-chat-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New message"),),
      body: Column(
        children: [
          SizedBox(height: 5,),
          Expanded(child: SingleChildScrollView(child: Container(height : MediaQuery.of(context).size.height*0.8,child: DirectLoadUsers())))
        ],
      ),
    );
  }
}
