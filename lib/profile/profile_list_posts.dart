import 'package:flutter/material.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/res/images.dart';

class ProfilePostsList extends StatelessWidget {
  final PostFrom postFrom;
  final String anotherUserId;
  ProfilePostsList(this.postFrom,this.anotherUserId);

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            InstagramImages.instagram_text_logo,
            width: 100,
            height: 30,
            fit: BoxFit.fill,
          ),
          actions: [IconButton(onPressed: () {
          }, icon: Icon(Icons.send))],
        ),
        body: PostsList(postFrom,anotherUserId),
      );
  }
}
