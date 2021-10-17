import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/profile/profile_grid_view_item.dart';
import 'package:provider/provider.dart';

class ProfileGridView extends StatefulWidget {
  final bool isLikedPost;
  final String anotherUserId;
  final bool isPageView;

  ProfileGridView(this.isLikedPost, this.anotherUserId, this.isPageView);

  @override
  _ProfileGridViewState createState() => _ProfileGridViewState();
}

class _ProfileGridViewState extends State<ProfileGridView> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppPosts>(context, listen: false)
        .getProfilePostsList(
            widget.isLikedPost, widget.isPageView, widget.anotherUserId);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          futureItems = Provider.of<AppPosts>(context, listen: false)
              .getProfilePostsList(
              widget.isLikedPost, widget.isPageView, widget.anotherUserId);
        });
      },
      child: FutureBuilder(
          future: futureItems,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final document = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 3),
              itemBuilder: (context, index) {
                if (!widget.isLikedPost) {
                  return ProfileGridViewItem(
                      document[index]["imageUrl"], PostFrom.Profile,widget.anotherUserId);
                } else {
                  return ProfileGridViewItem(
                      document[index]["imageUrl"], PostFrom.LikedProfile,widget.anotherUserId);
                }
              },
              itemCount: document.length,
            );
          }),
    );
  }
}
