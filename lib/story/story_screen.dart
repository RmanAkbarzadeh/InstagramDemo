import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_demo/fetch_data.dart';
import 'package:instagram_demo/models/story.dart';
import 'package:instagram_demo/story/story_bar.dart';
import 'package:instagram_demo/story/story_item.dart';
import 'package:provider/provider.dart';

class StoryScreen extends StatefulWidget {
  final String userId;

  StoryScreen(this.userId);

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  Future<QuerySnapshot<Map<String, dynamic>>>? futureItems;
  PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _barFillAnimation;
  final user = FirebaseAuth.instance.currentUser;
  FetchData fetchData = FetchData();
  late final storiesSize;
  bool isSizeLoad = false;
  bool _isLoading = false;
  bool isRun = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureItems = Provider.of<AppStories>(context, listen: false)
        .getStoriesWithUserId(widget.userId);
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _barFillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    _isLoading = true;
    fetchData.fetchData(widget.userId).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    if(!isSizeLoad) {
      storiesSize =
      await Provider.of<AppStories>(context, listen: false).getStoriesSize(
          widget.userId);
      print(storiesSize);
    }
    setState(() {
      isSizeLoad = true;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
    _pageController.dispose();
  }


  void _autoMove(int length) async {
      await _animationController.forward();
      Timer.run(() {
        if (_currentPage < length - 1) {
         _currentPage++;
        } else {
          Navigator.of(context).pop();
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    }

  void _onTap(TapUpDetails details)  {
    final deviceWidth = MediaQuery.of(context).size.width;
    var dx = details.globalPosition.dx;
    if (dx < deviceWidth / 2) {
      _animationController.reset();
      if(_currentPage > 0) {
        _currentPage--;
        _pageController.previousPage(
            duration: Duration(microseconds: 1), curve: Curves.easeIn);
      }
    } else {
      _animationController.reset();
      if (_currentPage < storiesSize -1) {
        _currentPage++;
        _pageController.nextPage(
            duration: Duration(microseconds: 1), curve: Curves.easeIn);
      }else{
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPress: () {
          _animationController.stop();
        },
        onLongPressEnd: (details) {
          _animationController.forward();
        },
        onTapUp: (details) =>_currentPage == 0 ? details.globalPosition.dx < MediaQuery.of(context).size.width/2  ? null : _onTap(details) : _onTap(details),
        child: FutureBuilder(
            future: futureItems,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center();
              }
              final document = snapshot.data!.docs;
              final storiesList = document[0]["storiesList"] as List<dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Stack(
                  children: [
                    PageView.builder(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return StoryItem(
                              imageUrl: storiesList[index]["imageUrl"],
                              postTime: storiesList[index]["createdAt"],
                              autoMove : _autoMove,
                              storiesLength : storiesList.length,
                              anotherUserId : widget.userId
                          );
                        },
                        itemCount: storiesList.length),
                    Container(
                      height: 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return StoryBar(_barFillAnimation, storiesList.length,
                              index, _currentPage);
                        },
                        itemCount: storiesList.length,
                      ),
                    ),
                    Positioned(
                      child: Row(
                        children: [
                          !_isLoading ? CachedNetworkImage(
                            imageBuilder: (context, imageProvider) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            fit: BoxFit.cover,
                            imageUrl: fetchData.photoImage,
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ) : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            fetchData.username,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                      top: 20,
                      left: 10,
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
