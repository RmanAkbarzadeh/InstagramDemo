import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_screen.dart';
import 'package:instagram_demo/get_profile_image.dart';
import 'package:instagram_demo/models/direct.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';

class DirectChatListItem extends StatefulWidget {
  final String userId;

  DirectChatListItem(this.userId);

  @override
  _DirectChatListItemState createState() => _DirectChatListItemState();
}

class _DirectChatListItemState extends State<DirectChatListItem> {
  String? userName;
  bool _isLoading = false;

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
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return _isLoading
        ? Center()
        : StreamBuilder(
            stream: Provider.of<AppDirects>(context, listen: false)
                .getMessage(widget.userId),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
                final document = snapshot.data!.docs;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DirectChatScreen(widget.userId),));
                    },
                    child: ListTile(
                      leading: Container(
                          width: 70,
                          height: 70,
                          child: GetProfileImage(widget.userId, 50, "", false)),
                      title: Text(userName as String),
                      subtitle: Row(
                        children: [
                          Container(
                              constraints: BoxConstraints(
                                  maxWidth: deviceSize.width * 0.5
                              ),
                              child: Text(
                               document.length==0 ? "Write an message !" : document[0]["message"],
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              )),
                          SizedBox(width: 10,),
                          document.length==0 ? Center() : Text("• " +
                              Provider.of<AppDirects>(context, listen: false)
                                  .daysBetween(
                                  (document[0]["createdAt"]
                                  as Timestamp)
                                      .toDate(),
                                  DateTime.now()),
                            style: TextStyle(color: Colors.grey),
                          )
                        ],
                      ),
                      trailing: Icon(Icons.camera_alt_outlined),
                    ),
                  ),
                );
            });
  }
}
