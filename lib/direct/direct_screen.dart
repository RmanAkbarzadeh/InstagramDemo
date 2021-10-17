import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_list.dart';
import 'package:instagram_demo/direct/direct_new_chat_screen.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';

class DirectScreen extends StatefulWidget {
  const DirectScreen({Key? key}) : super(key: key);
  static const String routeName = "/direct-screen";

  @override
  _DirectScreenState createState() => _DirectScreenState();
}

class _DirectScreenState extends State<DirectScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? userName;
  bool _isLoading = false;

  @override
  void didChangeDependencies() async{
    // TODO: implement didChangeDependencies
    _isLoading = true;
    userName =await Provider.of<AppUsers>(context,listen: false).getUserName(user!.uid);
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading ? Center(child: CircularProgressIndicator(),) : Scaffold(
      appBar: AppBar(
        title: Text(userName as String),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.video_call_outlined,size: 40,)),
          SizedBox(width: 10,),
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(DirectNewChatScreen.routeName);
          }, icon: Icon(Icons.edit_location_outlined,size: 30,)),
          SizedBox(width: 5,),
        ],
      ),
      body: DirectChatList(),
    );
  }
}
