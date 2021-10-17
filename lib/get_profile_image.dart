import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/res/images.dart';
import 'package:provider/provider.dart';

class GetProfileImage extends StatefulWidget {
  final String userId;
  final double Size;
  final String username;
  final bool isComment;
  GetProfileImage(this.userId,this.Size,this.username,this.isComment);

  @override
  _GetProfileImageState createState() => _GetProfileImageState();
}

class _GetProfileImageState extends State<GetProfileImage> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;

  final user = FirebaseAuth.instance.currentUser;



  bool isUpdate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppUsers>(context,listen: false).getSpecificUser(widget.isComment, widget.userId, widget.username);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futureItems,
      builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center();
        }
        final document = snapshot.data!.docs;
        return CachedNetworkImage(
          imageBuilder: (context, imageProvider) => Container(
            width: widget.Size,
            height: widget.Size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          fit: BoxFit.cover,
          imageUrl: document[0]["profileImage"],
          placeholder: (context, url) => Image.asset(InstagramImages.simple_profile_image_placeholder,width: widget.Size,height: widget.Size,),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
      }
    );
  }
}
