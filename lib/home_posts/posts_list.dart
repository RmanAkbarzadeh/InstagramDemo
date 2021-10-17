import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/home_posts/posts_item_list.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/story/story_list.dart';
import 'package:provider/provider.dart';

enum PostFrom { Home, Profile, LikedProfile }

class PostsList extends StatefulWidget {
  static const String routeName = "posts-list-page";
  final PostFrom postFrom;
  final String anotherUserId;

  PostsList(this.postFrom, this.anotherUserId);

  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppPosts>(context, listen: false)
        .getPostsList(widget.postFrom, widget.anotherUserId);

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          futureItems = Provider.of<AppPosts>(context, listen: false)
              .getPostsList(widget.postFrom, widget.anotherUserId);
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
          var document;
          if (snapshot.data != null) {
            document = snapshot.data!.docs;
            return Column(
              children: [
                if (PostFrom.Home == widget.postFrom) StoryList(),
                Expanded(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    itemBuilder: (context, index) {
                      bool _isLike = false;
                      List<dynamic> likedMember =
                          document[index]["likedMember"];
                      likedMember.forEach((userId) {
                        if (userId == user!.uid) {
                          _isLike = true;
                        }
                      });
                      if (document[index]["userId"] == user!.uid) {
                        return PostItemList(
                          docIndex: index,
                          isMyPost: true,
                          isLike: _isLike,
                          userId: document[index]["userId"],
                          imageUrl: document[index]["imageUrl"],
                          description: document[index]["description"],
                          location: document[index]["location"],
                          username: document[index]["username"],
                          likes: document[index]["likes"],
                          comments: document[index]["comments"],
                          postTime: document[index]["createdAt"],
                          postFrom: widget.postFrom,
                        );
                      } else {
                        return PostItemList(
                          docIndex: index,
                          isMyPost: false,
                          isLike: _isLike,
                          userId: document[index]["userId"],
                          imageUrl: document[index]["imageUrl"],
                          description: document[index]["description"],
                          location: document[index]["location"],
                          username: document[index]["username"],
                          likes: document[index]["likes"],
                          comments: document[index]["comments"],
                          postTime: document[index]["createdAt"],
                          postFrom: widget.postFrom,
                        );
                      }
                    },
                    itemCount: document.length,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                if (PostFrom.Home == widget.postFrom) StoryList(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
                Center(
                  child: Text(
                    "Follow others to see their posts !",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
