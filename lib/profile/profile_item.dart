import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/direct/direct_chat_screen.dart';
import 'package:instagram_demo/fetch_data.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/profile/edit_profile_page.dart';
import 'package:instagram_demo/res/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_demo/story/story_screen.dart';
import 'package:provider/provider.dart';

class ProfileItem extends StatefulWidget {
  final int postsLength;
  final String anotherUserId;
  final bool isPageView;

  ProfileItem(this.postsLength, this.anotherUserId, this.isPageView);

  @override
  _ProfileItemState createState() => _ProfileItemState();
}

class _ProfileItemState extends State<ProfileItem> {
  bool isFollow = false;
  Stream<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;
  bool isUpdate = false;
  bool isLoading = false;
  FetchData fetchData = FetchData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppPosts>(context,listen: false).getProfileInfoLive(widget.isPageView, widget.anotherUserId);
    isLoading = true;
    fetchData.fetchData(widget.anotherUserId).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return isLoading == false ? StreamBuilder(
        stream: futureItems,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }
          final document = snapshot.data!.docs;
          final followersList = document[0]["followers"] as List<dynamic>;
          final followingList = document[0]["following"] as List<dynamic>;
          isFollow = followersList.contains(user!.uid);
          return Container(
            padding: EdgeInsets.all(12),
            height: 210,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if(widget.isPageView) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StoryScreen(user!.uid),));
                        }else{
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => StoryScreen(widget.anotherUserId),));
                        }
                      },
                      child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        fit: BoxFit.cover,
                        imageUrl: fetchData.photoImage,
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          widget.postsLength.toString(),
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text("posts")
                      ],
                    ),
                    Column(
                      children: [
                        Text(followersList.length.toString(),
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("followers")
                      ],
                    ),
                    Column(
                      children: [
                        Text(followingList.length.toString(),
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("following")
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  document[0]["name"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  document[0]["bio"],
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70),
                ),
                SizedBox(
                  height: 10,
                ),
                if (widget.anotherUserId == user!.uid)
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: 30, minWidth: deviceSize.width * 0.9),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                  EditProfilePage.routeName,
                                  arguments: {
                                    "name": document[0]["name"],
                                    "bio": document[0]["bio"]
                                  }).then((value) {
                                setState(() {
                                  isUpdate = true;
                                });
                              });
                            },
                            child: Text("Edit profile"),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  InstagramColor.backgroundColor),
                            ),
                          ),
                        )),
                  ),
                if (widget.anotherUserId != user!.uid)
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: isFollow
                            ? Container(
                              decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: 35
                                ),
                                child: ElevatedButton(
                                    onPressed: (){
                                      Provider.of<AppPosts>(context,listen: false).toggleFollow(isFollow, widget.anotherUserId, context);
                                      setState(() {
                                        isFollow = !isFollow;
                                      });
                                    }, child: Text("Following"),style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all<Color>(
                                    Colors.black))),
                              ),
                            )
                            : ElevatedButton(
                                onPressed: (){
                                  Provider.of<AppPosts>(context,listen: false).toggleFollow(isFollow, widget.anotherUserId, context);
                                  setState(() {
                                    isFollow = !isFollow;
                                  });
                                }, child: Text("Follow")),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 35),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      DirectChatScreen(widget.anotherUserId),));
                              },
                              child: Text("Message"),
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black)),
                            ),
                          ),
                        ),
                      )),
                    ],
                  )
              ],
            ),
          );
        }) : Center(child: CircularProgressIndicator(),);
  }
}
