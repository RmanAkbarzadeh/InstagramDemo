import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppUser{
  final String bio;
  final String emai;
  final String name;
  final String imageUrl;
  final String userId;
  final String username;
  final List<dynamic> followers;
  final List<dynamic> following;


  AppUser({required this.bio,required this.emai,required this.name,required this.imageUrl,required this.userId,
     required this.username,required this.followers,required this.following});


}

class AppUsers with ChangeNotifier{
  final List<AppUser> _usersList = [];

  List<AppUser> get usersList {
    return [..._usersList];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers()  {
    final response =  FirebaseFirestore.instance.collection("users").snapshots();
    return response;
  }

  Future<List> getFollowingUsers() async {
    final _currentUser = FirebaseAuth.instance.currentUser;
    final response = await FirebaseFirestore.instance.collection("users").doc(_currentUser!.uid).get();
    final List<dynamic> followingList = response["following"];
    return followingList;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getSpecificUser(bool isComment,String userId,String username) async {
    var response ;
    if(!isComment) {
      response = FirebaseFirestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .get();
    }else{
      response = FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username)
          .get();
    }
    return response;
  }

  Future<String> getUserName(String userId) async {
    String username = "";
    var response = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();
    if (response.exists) {
      Map<String, dynamic>? data = response.data();
      username = data?['username'];
      notifyListeners();
      return username;
    }
    return "not found";
  }

  Future<void> changeProfileImage(File image) async {
    final _currentUser = FirebaseAuth.instance.currentUser;
    final ref = FirebaseStorage.instance.ref().child("user_posts_images").child("${_currentUser!.uid}").child(DateTime.now().toString()+".jpg");
    await ref.putFile(image as File);
    final url = await ref.getDownloadURL();
    await FirebaseFirestore.instance.collection("users").doc(_currentUser.uid).update({
      "profileImage" : url
    });
  }

  void updateProfile(TextEditingController _nameController ,TextEditingController _bioController , BuildContext context ) async{
    final _currentUser = FirebaseAuth.instance.currentUser;
    if(_bioController.text.isEmpty || _nameController.text.isEmpty){
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_currentUser!.uid)
          .update({
        "name": _nameController.text,
        "bio": _bioController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated !"),backgroundColor: Colors.grey,));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),backgroundColor: Theme.of(context).errorColor,));
    }
  }


}