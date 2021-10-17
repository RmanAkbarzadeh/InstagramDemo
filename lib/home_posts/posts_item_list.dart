import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/res/images.dart';
import 'package:instagram_demo/screens/comment_page.dart';
import 'package:instagram_demo/screens/home_page.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';

import '../get_profile_image.dart';

class PostItemList extends StatefulWidget {
  int docIndex;
  final bool isMyPost;
  bool isLike;
  final String imageUrl;
  final String userId;
  final String description;
  final String location;
  final String username;
  int likes;
  final int comments;
  final Timestamp postTime;
  final PostFrom postFrom;

  PostItemList(
      {required this.docIndex,
      required this.isMyPost,
      required this.isLike,
      required this.userId,
      required this.imageUrl,
      required this.description,
      required this.location,
      required this.username,
      required this.likes,
      required this.comments,
      required this.postTime,
      required this.postFrom});

  @override
  _PostItemListState createState() => _PostItemListState();
}

class _PostItemListState extends State<PostItemList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _likeAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _likeAnimation = Tween<double>(begin: 0.0, end: 130.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }


  void _toggleLike(){
    Provider.of<AppPosts>(context,listen: false).toggleLikes(widget.isLike, widget.likes, widget.docIndex,widget.postFrom,widget.userId,context);
    setState(() {
      if(widget.isLike){
        widget.likes--;
      }else{
        widget.likes++;
      }
      widget.isLike = !widget.isLike;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GetProfileImage("",40,widget.username,true),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      widget.location,
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
              if (widget.isMyPost)
                DropdownButton<String>(
                  hint: Icon(Icons.more_vert),
                  elevation: 0,
                  underline: Text(""),
                  items: <String>[
                    'Delete',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      switch (value) {
                        case "Delete":
                          {
                            Provider.of<AppPosts>(context,listen: false).deletePost(widget.postFrom, widget.docIndex, widget.userId);
                            break;
                          }
                      }
                    });
                    Navigator.of(context).pushReplacementNamed(HomePage.routeName);
                  },
                ),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          GestureDetector(
            onDoubleTap: () async {
              if(widget.isLike == false){
                _toggleLike();
                //_toggleLikes();
              }
              await _animationController.forward();
              Future.delayed(Duration(milliseconds: 700)).then((value) => _animationController.reverse());
            },
            child: Container(
              height: 300,
              child: PinchZoom(
                child: Stack(alignment: Alignment.center, children: [
                  FadeInImage(
                    placeholder: AssetImage(InstagramImages.placeholder),
                    image: NetworkImage(widget.imageUrl),
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  Icon(
                    Icons.favorite,
                    size: _likeAnimation.value,
                    color: Colors.white,
                  )
                ]),
                resetDuration: const Duration(milliseconds: 100),
                maxScale: 2.5,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 40),
            child: Row(
              children: [
                IconButton(
                      onPressed:() => _toggleLike(),
                      icon: widget.isLike
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(
                              Icons.favorite_border,
                            )),
                IconButton(
                    onPressed: () async{
                      final documentId = await Provider.of<AppPosts>(context,listen: false).getDocument(widget.postFrom,widget.docIndex,widget.userId);
                      Navigator.of(context).pushNamed(CommentPage.routeName,arguments:{
                        "documentId" : documentId.id,
                        "comments" : widget.comments
                      });
                    },
                    icon: Icon(
                      Icons.mode_comment_outlined,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.send,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "${widget.likes} likes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 10),
            child: Text(
              widget.username,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 2,
              left: 10,
            ),
            child: Text(
              widget.description,
              style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.9)),
            ),
          ),
          if (widget.comments > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 10),
              child: GestureDetector(
                  onTap: () async{
                    final documentId = await Provider.of<AppPosts>(context,listen: false).getDocument(widget.postFrom,widget.docIndex,widget.userId);
                    print(documentId.id);
                    Navigator.of(context).pushNamed(CommentPage.routeName,arguments:{
                      "username" : widget.username,
                      "documentId" : documentId.id,
                      "comments" : widget.comments
                    });
                  },
                  child: Text(
                    "View all ${widget.comments} comments",
                    style: TextStyle(color: Colors.grey),
                  )),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 10),
            child: Text(
              //daysBetween(widget.postTime.toDate(), DateTime.now()),
              Provider.of<AppPosts>(context,listen: false).daysBetween(widget.postTime.toDate(), DateTime.now()),
              style: TextStyle(color: Colors.grey,fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}
