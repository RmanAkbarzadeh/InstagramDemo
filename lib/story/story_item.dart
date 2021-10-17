import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:instagram_demo/cache_management.dart';
import 'package:instagram_demo/models/story.dart';
import 'package:provider/provider.dart';

class StoryItem extends StatefulWidget {
  final String imageUrl;
  final Timestamp postTime;
  final Function autoMove;
  final int storiesLength;
  final String anotherUserId;

  StoryItem(
      {required this.imageUrl,
      required this.postTime,
      required this.autoMove,
      required this.storiesLength,
      required this.anotherUserId});

  @override
  _StoryItemState createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  File? imageFile;

  bool _isImageLoading = false;
  bool _autoMove = false;

  Future<void> _getImage() async {
    var image = await CustomCacheManager.instance
        .getSingleFile(widget.imageUrl);
    imageFile = image;
    setState(() {
      _isImageLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    if (!_isImageLoading) {
      _getImage();
    }
    if (_isImageLoading) {
      if (!_autoMove) {
        widget.autoMove(widget.storiesLength);
        setState(() {
          _autoMove = true;
        });
      }
    }
    return Scaffold(
        body: Stack(
      children: [
        Container(
            width: deviceSize.width,
            height: deviceSize.height,
            child: imageFile == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Image.file(imageFile as File)),
        Positioned(
            left: 140,
            top: 31,
            child: Text(
              Provider.of<AppStories>(context, listen: false)
                  .storyTimeBetween(widget.postTime.toDate(), DateTime.now(),widget.anotherUserId,widget.postTime,widget.imageUrl),
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ))
      ],
    ));
  }
}
