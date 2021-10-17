import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/get_profile_image.dart';
import 'package:instagram_demo/models/story.dart';
import 'package:instagram_demo/story/add_new_story_screen.dart';
import 'package:instagram_demo/story/story_avatar_item.dart';
import 'package:provider/provider.dart';

class StoryList extends StatefulWidget {
  const StoryList({Key? key}) : super(key: key);

  @override
  _StoryListState createState() => _StoryListState();
}

class _StoryListState extends State<StoryList> {
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppStories>(context,listen: false).getAllUsersWithStory();
  }


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          futureItems = Provider.of<AppStories>(context,listen: false).getAllUsersWithStory();
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
          if(snapshot.data != null) {
            document = snapshot.data!.docs;
            return Row(
              children: [
                Container(
                  width: 100,
                  height: 115,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          AddNewStoryScreen.routeName);
                    },
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          left: 10,
                          child: Column(
                            children: [
                              GetProfileImage(user!.uid, 70, "", false),
                              SizedBox(height: 3,),
                              Text(
                                "Your Story", style: TextStyle(fontSize: 12),),
                            ],
                          ),
                        ),
                        Positioned(bottom: 40, right: 20, child: Icon(Icons
                            .add_circle_sharp, color: Colors.blue, size: 20,))
                      ],
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 115,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StoryAvatarItem(document[index].id),
                      );
                    },
                    itemCount: document.length,
                  ),
                ),
              ],
            );
          }else {
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 115,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        AddNewStoryScreen.routeName);
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 10,
                        child: Column(
                          children: [
                            GetProfileImage(user!.uid, 70, "", false),
                            SizedBox(height: 3,),
                            Text(
                              "Your Story", style: TextStyle(fontSize: 12),),
                          ],
                        ),
                      ),
                      Positioned(bottom: 40, right: 20, child: Icon(Icons
                          .add_circle_sharp, color: Colors.blue, size: 20,))
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
