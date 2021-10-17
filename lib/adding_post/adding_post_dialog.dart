import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_demo/adding_post/adding_post_detail.dart';

class AddingPostDialog extends StatelessWidget {
  const AddingPostDialog({Key? key}) : super(key: key);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 7,bottom: 15),
              child: Text(
                "Create a post",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                final pickedImageRes = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                final imageFile = File(pickedImageRes!.path);
                Navigator.of(context).pushNamed(AddingPostDetail.routeName,arguments: {
                  "pickedImage" : imageFile
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
                  final pickedImageRes = await ImagePicker.platform.pickImage(source: ImageSource.camera);
                  final imageFile = File(pickedImageRes!.path);
                  Navigator.of(context).pushNamed(AddingPostDetail.routeName,arguments: {
                   "pickedImage" : imageFile
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
