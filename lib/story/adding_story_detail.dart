import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
import 'package:screenshot/screenshot.dart';

class AddingStoryDetail extends StatefulWidget {
  const AddingStoryDetail({Key? key}) : super(key: key);
  static const String routeName = "/adding-story-detaile";

  @override
  _AddingStoryDetailState createState() => _AddingStoryDetailState();
}

class _AddingStoryDetailState extends State<AddingStoryDetail> {
  File? image;
  String? text;
  Color? textColor;
  double? textSize;
  bool isUploading = false;
  final user = FirebaseAuth.instance.currentUser;
  bool isInContainer = true;
  ScreenshotController _screenshotController = ScreenshotController();
  Uint8List? _storyImage;

  double _x = 100;
  double _angle = (math.pi / 180) * 0.01;
  double _y = 100;
  double handleSize = 30;
  double _oldAngle = 0.0;
  double _angleDelta = 0.0;


  void _saveStory() async {
    if (image == null) {
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    await giveStoryImage();
    UploadTask ref = FirebaseStorage.instance
        .ref()
        .child("user_story")
        .child("${user!.uid}")
        .child(DateTime.now().toString() + ".png").putData(_storyImage as Uint8List);
    final url = await (await ref).ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection("stories")
        .doc(user.uid)
        .update({
      "storiesList": FieldValue.arrayUnion([
        {
          "createdAt": Timestamp.now(),
          "imageUrl": url,
        }
      ]),
      "userId": user.uid,
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    setState(() {
      isUploading = false;
    });
  }

  Future<void> giveStoryImage() async{
    setState(() {
      isUploading = true;
    });
    await _screenshotController.capture().then((value) {
      _storyImage = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;

    if (arguments != null) {
      image = arguments["pickedImage"];
      text = arguments["text"];
      textColor = arguments["textColor"];
      textSize = arguments["textSize"];
    }
    ;

    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("New Story"),
        actions: [
          isUploading
              ? CircularProgressIndicator()
              : TextButton(
                  onPressed: () async{
                    await giveStoryImage();
                    _saveStory();
                  },
                  child: Text(
                    "Share",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Screenshot(
          controller: _screenshotController,
          child: Stack(
            children: [
              Image.file(
                image as File,
                fit: BoxFit.fill,
                width: double.infinity,
                height: deviceHeight,
              ),
              Positioned(
                top: _y,
                left: _x,
                child: GestureDetector(
                  onPanUpdate: (DragUpdateDetails details) {
                    setState(() {
                      _x += details.delta.dx;
                      _y += details.delta.dy;
                    });
                  },
                  child: Transform.rotate(
                    angle: _angle,
                    child: Column(
                      children: [
                        if(!isUploading)
                          Container(
                          width: handleSize,
                          height: handleSize,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/rotate_image.jpg"),
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(handleSize),
                            border: Border.all(
                              width: 5,
                              color: Colors.white,
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              //   Offset centerOfGestureDetector = Offset(
                              // constraints.maxWidth / 2, constraints.maxHeight / 2);
                              /**
                               * using center of positioned element instead to better fit the
                               * mental map of the user rotating object.
                               * (height = container height (30) + container height (30) + container height (200)) / 2
                               */
                              Offset centerOfGestureDetector = Offset(
                                  constraints.maxWidth / 2, _x + handleSize);
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanStart: (details) {
                                  final touchPositionFromCenter =
                                      details.localPosition -
                                          centerOfGestureDetector;
                                  _angleDelta = _oldAngle -
                                      touchPositionFromCenter.direction;
                                },
                                onPanEnd: (details) {
                                  setState(
                                    () {
                                      _oldAngle = _angle;
                                    },
                                  );
                                },
                                onPanUpdate: (details) {
                                  final touchPositionFromCenter =
                                      details.localPosition -
                                          centerOfGestureDetector;

                                  setState(
                                    () {
                                      _angle = touchPositionFromCenter.direction +
                                          _angleDelta;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if(!isUploading)
                          Container(
                          height: handleSize,
                          width: 1,
                          color: Colors.white,
                        ),
                        if(isUploading)
                          Container(
                            width: handleSize,
                            height: 2*handleSize,
                          ),
                        Text(
                          text as String,
                          style: TextStyle(fontSize: textSize, color: textColor),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
