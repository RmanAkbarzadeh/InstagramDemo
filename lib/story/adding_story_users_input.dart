import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../get_profile_image.dart';
import 'adding_story_detail.dart';

class AddingStoryUseresInput extends StatefulWidget {
  const AddingStoryUseresInput({Key? key}) : super(key: key);
  static const String routeName = "/adding-story-users-input";

  @override
  _AddingStoryUseresInputState createState() => _AddingStoryUseresInputState();
}

class _AddingStoryUseresInputState extends State<AddingStoryUseresInput> {
  var _descriptionController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  File? image;
  String textSize = "16";
  double size = 16;
  String color = "White";
  Color finalColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    if (arguments != null) {
      image = arguments["pickedImage"];
    }
    ;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("New Story"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AddingStoryDetail.routeName,
                    arguments: {
                  "pickedImage": image,
                      "text" : _descriptionController.text,
                      "textSize" : size,
                      "textColor" : finalColor
                });
              },
              child: Text("Next"))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
                icon: GetProfileImage(user!.uid, 50, "", false),
                hintText: "Write your text here ...",
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Colors.black,
                filled: true),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    "Pick your text color :",
                    style: TextStyle(fontSize: 20),
                  )),
                  DropdownButton<String>(
                    hint: Text(color),
                    items: <String>[
                      'White',
                      'Black',
                      'Red',
                      'Yellow',
                      'Blue',
                      'Green',
                      'Purple',
                      'Pink',
                      'Orange'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        color = value as String;
                        switch (value) {
                          case "White":
                            {
                              finalColor = Colors.white;
                              break;
                            }
                          case "Black":
                            {
                              finalColor = Colors.black;
                              break;
                            }
                          case "Red":
                            {
                              finalColor = Colors.red;
                              break;
                            }
                          case "Yellow":
                            {
                              finalColor = Colors.yellow;
                              break;
                            }
                          case "Blue":
                            {
                              finalColor = Colors.blue;
                              break;
                            }
                          case "Green":
                            {
                              finalColor = Colors.green;
                              break;
                            }
                          case "Purple":
                            {
                              finalColor = Colors.purple;
                              break;
                            }
                          case "Pink":
                            {
                              finalColor = Colors.pink;
                              break;
                            }
                          case "Orange":
                            {
                              finalColor = Colors.orange;
                              break;
                            }
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    "Pick your text size :",
                    style: TextStyle(fontSize: 20),
                  )),
                  DropdownButton<String>(
                    hint: Text(textSize),
                    items: <String>[
                      "16",
                      "18",
                      "20",
                      "22",
                      "24",
                      "26",
                      "28",
                      "30",
                      "32",
                      "34",
                      "36",
                      "38",
                      "40"
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        textSize = value as String;

                        switch (value) {
                          case "16" : {
                            size = 16.0;
                            break;
                          }
                          case "18" : {
                            size = 18.0;
                            break;
                          }case "20" : {
                            size = 20.0;
                            break;
                          }case "22" : {
                            size = 22.0;
                            break;
                          }case "24" : {
                            size = 24.0;
                            break;
                          }case "26" : {
                            size = 26.0;
                            break;
                          }case "28" : {
                            size = 28.0;
                            break;
                          }case "30" : {
                            size = 30.0;
                            break;
                          }case "32" : {
                            size = 32.0;
                            break;
                          }case "34" : {
                            size = 34.0;
                            break;
                          }case "36" : {
                            size = 36.0;
                            break;
                          }case "38" : {
                            size = 38.0;
                            break;
                          }case "40" : {
                            size = 40.0;
                            break;
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
