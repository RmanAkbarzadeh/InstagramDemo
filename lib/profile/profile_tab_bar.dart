import 'package:flutter/material.dart';
import 'package:instagram_demo/profile/profile_grid_view.dart';
import 'package:instagram_demo/res/colors.dart';

class ProfileTabBar extends StatelessWidget {
  final String anotherUserId;
  final bool isPageView;

  ProfileTabBar(this.anotherUserId,this.isPageView);

  @override
  Widget build(BuildContext context) {
      return Expanded(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: AppBar(
                bottom: TabBar(
                  indicatorColor: InstagramColor.textColor,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.grid_on_rounded),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.favorite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                  children: [
                    if(isPageView)
                      ProfileGridView(false,anotherUserId,true),
                    if(isPageView)
                      ProfileGridView(true,anotherUserId,true),
                    if(!isPageView)
                      ProfileGridView(false,anotherUserId,false),
                    if(!isPageView)
                      ProfileGridView(true,anotherUserId,false),
              ]),
            )
          ],
        ),
      );
  }
}
