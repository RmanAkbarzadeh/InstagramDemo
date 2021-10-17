import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/get_profile_image.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddingPostDetail extends StatefulWidget {
  static const String routeName = "/adding-detaile-screen";

  @override
  _AddingPostDetailState createState() => _AddingPostDetailState();
}

class _AddingPostDetailState extends State<AddingPostDetail> {
   File? image;
   bool isUploading = false;
   var _descriptionController = TextEditingController();
   var _locationController = TextEditingController();
   final user = FirebaseAuth.instance.currentUser;

   Future<void> getLocation() async{
     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
     List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude,position.longitude);
     _locationController.text = "${placeMarks[0].locality} , ${placeMarks[0].country}";
   }


   void _savePost() async {
     setState(() {
       isUploading = true;
     });
     if (_locationController.text.isEmpty || image == null || _descriptionController.text.isEmpty) {
       return;
     }
     final user = FirebaseAuth.instance.currentUser;
     final ref = FirebaseStorage.instance.ref().child("user_posts_images").child("${user!.uid}").child(DateTime.now().toString()+".jpg");
     await ref.putFile(image as File);
     final url = await ref.getDownloadURL();
     String username = await Provider.of<AppUsers>(context,listen: false).getUserName(user.uid);

     await FirebaseFirestore.instance.collection("posts").doc(DateTime.now().toString()).set({
       "comments" : 0,
       "description" : _descriptionController.text,
       "imageUrl" : url,
       "likes" : 0,
       "location" : _locationController.text,
       "userId" : user.uid,
       "username" : username,
       "createdAt": DateTime.now(),
       "likedMember":[]
     });
     Navigator.of(context).pop();
     Navigator.of(context).pop();
     setState(() {
       isUploading=false;
     });
   }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;

    if (arguments != null) {
      image = arguments["pickedImage"];
    };

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("New Post"),
        actions: [isUploading ? CircularProgressIndicator() : TextButton(onPressed: _savePost, child: Text("Share"))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.file(
                image as File,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    icon: GetProfileImage(user!.uid,50,"",false),
                    hintText: "Write caption here ...",
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black,
                    filled: true
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                    icon: Icon(Icons.location_on,size: 40,),
                    hintText: "Share your location !",
                    hintStyle: TextStyle(color: Colors.white),
                    fillColor: Colors.black,
                    filled: true
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(onPressed: getLocation, icon: Icon(Icons.location_on), label: Text("Take my location"))
            ],
          ),
        ),
      ),
    );
  }
}
