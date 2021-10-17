import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_screen_bubble.dart';
import 'package:instagram_demo/get_profile_image.dart';
import 'package:instagram_demo/models/direct.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';

class DirectChatScreen extends StatefulWidget {
  final String userId;

  DirectChatScreen(this.userId);

  static const String routeName = "/direct-chat-screen";

  @override
  _DirectChatScreenState createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  String? userName;
  bool _isLoading = false;
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    _isLoading = true;
    userName = await Provider.of<AppUsers>(context, listen: false)
        .getUserName(widget.userId);
    setState(() {
      _isLoading = false;
    });

    super.didChangeDependencies();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Row(
                children: [
                  GetProfileImage(widget.userId, 40, "", false),
                  SizedBox(width: 10,),
                  Text(userName as String),
                ],
              ),
              actions: [
                Icon(
                  Icons.call,
                  size: 25,
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.video_call_outlined,
                  size: 30,
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
            body: StreamBuilder(
                stream: Provider.of<AppDirects>(context, listen: false)
                    .getMessage(widget.userId),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final document = snapshot.data!.docs;
                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                child: ListView.builder(
                                  controller: _scrollController,
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return DirectChatScreenBubble(
                                        document[index]["userId"],
                                        document[index]["message"]);
                                  },
                                  itemCount: document.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: TextField(
                          onTap: (){
                            _scrollController.jumpTo(0);
                            print("dsdwddf");
                          },
                          autofocus: false,
                          controller: _messageController,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: CircleAvatar(backgroundColor: Colors.blue,child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),),
                              ),
                              suffixIcon: TextButton(
                                  onPressed: (){
                                    Provider.of<AppDirects>(context,listen: false).sendMessage(widget.userId, _messageController.text,context);
                                    //FocusScope.of(context).unfocus();
                                    _scrollController.jumpTo(0);
                                      _messageController.clear();
                                  },
                                  child: Text(
                                    "Send",
                                    style:TextStyle(color:Colors.blue, fontSize: 16)
                                  )),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(width: 1,color: Colors.grey )),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25),borderSide: BorderSide(width: 1,color: Colors.grey )),
                              hintText: "Message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              ),
                        ),
                      )
                    ],
                  );
                }),
          );
  }
}
