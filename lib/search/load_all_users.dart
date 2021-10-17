import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/search/users_list_item.dart';
import 'package:provider/provider.dart';

class LoadAllUsers extends StatefulWidget {
  @override
  _LoadAllUsersState createState() => _LoadAllUsersState();
}

class _LoadAllUsersState extends State<LoadAllUsers> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? futureItems;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppUsers>(context,listen: false).getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: futureItems,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final document = snapshot.data!.docs;
        return ListView.builder(
          itemBuilder: (context, index) {
            return UsersListItem(
                imageUrl : document[index]["profileImage"],
                username: document[index]["username"],
                name: document[index]["name"],
                userId: document[index].id,
            );
          },
          itemCount: document.length,
        );
      },
    );
  }
}
