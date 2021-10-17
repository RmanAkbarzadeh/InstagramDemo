import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:provider/provider.dart';

import '../get_profile_image.dart';

class CommentItem extends StatelessWidget {
  final String username;
  final String comment;
  final Timestamp commentTime;

  CommentItem(
      {required this.username,
      required this.comment,
      required this.commentTime,});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 60
          ),
          child: ListTile(
            leading: Container(width : 50, height: 50,child: GetProfileImage("",60,username,true)),
            title: Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              comment,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 73,bottom: 20),
          child: Text(
            Provider.of<AppPosts>(context,listen: false).daysBetween(commentTime.toDate(), DateTime.now()),
            style: TextStyle(color: Colors.grey,fontSize: 11),
          ),
        ),
        Divider(height: 1,color: Colors.grey,)
      ],
    );
  }
}
