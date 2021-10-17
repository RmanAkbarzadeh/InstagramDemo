import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:instagram_demo/comment/comment_item.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/res/colors.dart';
import 'package:provider/provider.dart';

import '../get_profile_image.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({Key? key}) : super(key: key);
  static const String routeName = "/comment-page";

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;
  var _commentController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool _isCommentEmpty = true;
  bool _isLoading = false;
  var arguments ;
  String? username;
  late String documentId;
  late int comments;
  bool isUserNameLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void didChangeDependencies() async{
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _commentController.addListener(_commentOnChanged);
    isUserNameLoad = true;
    username = await Provider.of<AppUsers>(context,listen: false).getUserName(user!.uid);
    setState(() {
      isUserNameLoad = false;
    });
    arguments = ModalRoute.of(context)!.settings.arguments as Map;
    documentId = arguments["documentId"];
    comments = arguments["comments"];
    futureItems = Provider.of<AppPosts>(context,listen: false).getComment(documentId);

  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _commentOnChanged(){
    if(_commentController.text.isEmpty){
      setState(() {
        _isCommentEmpty = true;
      });
    }
    if(!_commentController.text.isEmpty && _commentController.text.length == 1){
      setState(() {
        _isCommentEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(microseconds: 200),_scrollController.hasClients ? () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent) :()=>null,
    );

    return isUserNameLoad ? Center(child: CircularProgressIndicator(),) :  Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureItems = Provider.of<AppPosts>(context,listen: false).getComment(documentId);
          });
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    FutureBuilder(
                      future: futureItems,
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final document = snapshot.data!.docs;
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return CommentItem(
                              username: document[index]["username"],
                              comment: document[index]["comment"],
                              commentTime: document[index]["commentTime"],
                            );
                          },
                          itemCount: document.length,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 70,
              color: InstagramColor.comment_textfield_backgroundColor,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                          icon: GetProfileImage(user!.uid,50,"",false),
                          border: InputBorder.none,
                          hintText: "Comment as $username ...",
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor:
                              InstagramColor.comment_textfield_backgroundColor,
                          filled: true),
                    ),
                  ),
                  if(_isLoading)
                    CircularProgressIndicator(),
                  if(!_isLoading)
                    TextButton(
                      onPressed:
                          _isCommentEmpty ? null : () async{setState(() {
                            _isLoading = true;
                          });
                          await Provider.of<AppPosts>(context,listen: false).addComment(documentId, _commentController, context);
                          setState(() {
                            futureItems = Provider.of<AppPosts>(context,listen: false).getComment(documentId);
                            _isLoading = false;
                          });
                          },
                      child: Text(
                        "post",
                        style: _isCommentEmpty
                            ? TextStyle(color: Colors.grey, fontSize: 16)
                            : TextStyle(color: Colors.blue, fontSize: 16),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
