import 'package:flutter/material.dart';
import 'package:instagram_demo/res/images.dart';

import 'adding_story_dialog.dart';

class AddNewStoryScreen extends StatefulWidget {
  const AddNewStoryScreen({Key? key}) : super(key: key);
  static const String routeName = "/add-new-story-screen";

  @override
  _AddNewStoryScreenState createState() => _AddNewStoryScreenState();
}

class _AddNewStoryScreenState extends State<AddNewStoryScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                InstagramImages.adding_story_image,
                fit: BoxFit.cover,
                width: deviceSize.width * 0.5,
                height: deviceSize.height * 0.3,
              ),
              Container(
                  width: deviceSize.width * 0.5,
                  child: ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(context: context, builder: (context) {
                          return AddingStoryDialog();
                        },);
                      },
                      label: Text("Add a story")))
            ],
          ),
        ));;
  }
}
