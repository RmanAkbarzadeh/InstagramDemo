import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/screens/home_page.dart';
import 'package:instagram_demo/screens/profile_page.dart';
import 'package:provider/provider.dart';

class AddImageToProfile extends StatefulWidget {
  const AddImageToProfile({Key? key}) : super(key: key);

  @override
  _AddImageToProfileState createState() => _AddImageToProfileState();
}

class _AddImageToProfileState extends State<AddImageToProfile> {
  bool _isUploading = false;


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      backgroundColor: Colors.black,
      child: Container(
        padding: EdgeInsets.all(6),
        width: 200,
        height: 200,
        child:_isUploading ? Center(child: CircularProgressIndicator(),) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 7,bottom: 15),
              child: Text(
                "Pick an image",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                final pickedImageRes = await ImagePicker.platform.pickImage(source: ImageSource.gallery,imageQuality: 20,);
                final imageFile = File(pickedImageRes!.path);
                setState(() {
                  _isUploading = true;
                });
                await Provider.of<AppUsers>(context,listen: false).changeProfileImage(imageFile);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(HomePage.routeName);
                setState(() {
                  _isUploading = false;
                });
              },
              child: Text(
                "Add image from gallery",
                style: TextStyle(fontSize: 15),
              ),
              style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                final pickedImageRes = await ImagePicker.platform.pickImage(source: ImageSource.camera,imageQuality: 20);
                final imageFile = File(pickedImageRes!.path);
                setState(() {
                  _isUploading = true;
                });
                await Provider.of<AppUsers>(context,listen: false).changeProfileImage(imageFile);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(HomePage.routeName);
                setState(() {
                  _isUploading = false;
                });
              },
              child: Text(
                "Add image from camera",
                style: TextStyle(fontSize: 15),
              ),
              style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 15),
              ),
              style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
