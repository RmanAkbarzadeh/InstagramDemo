import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/post.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/profile/profile_item.dart';
import 'package:instagram_demo/profile/profile_tab_bar.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatefulWidget {
  static const String routeName = "/profile-page";
  final bool isPageView;
  ProfilePage({required this.isPageView});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileName = "";
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  final user = FirebaseAuth.instance.currentUser;
  String anotherUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isUpdate = false;
  String username = "";
  bool isUserNameLoading = false;

  @override
  void didChangeDependencies() async{
    // TODO: implement didChangeDependencies
    if(!widget.isPageView) {
      final arguments = ModalRoute
          .of(context)!
          .settings
          .arguments as Map;
      anotherUserId = arguments["userId"];
    }else{
      anotherUserId = FirebaseAuth.instance.currentUser!.uid;
    }
     futureItems = Provider.of<AppPosts>(context,listen: false).getProfileInfo(widget.isPageView,anotherUserId);
      isUserNameLoading = true;
      username = await Provider.of<AppUsers>(context,listen: false).getUserName(anotherUserId);
      setState(() {
        isUserNameLoading = false;
      });
    super.didChangeDependencies();

  }


  @override
  Widget build(BuildContext context) {

    return isUserNameLoading ? Center(child: CircularProgressIndicator(),) : FutureBuilder(
      future: Provider.of<AppPosts>(context,listen: false).getProfileInfo(widget.isPageView,anotherUserId),
      builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final document = snapshot.data!.docs;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text(username),
              ),
              body: Column(
                children: [
                  if(widget.isPageView)
                    ProfileItem(document.length, user!.uid, true),
                  if(!widget.isPageView)
                    ProfileItem(document.length, anotherUserId, false),
                  if(widget.isPageView)
                    ProfileTabBar(user!.uid, true),
                  if(!widget.isPageView)
                    ProfileTabBar(anotherUserId, false),

                ],
              ),
            ),
          );
      }
    );
  }
}
