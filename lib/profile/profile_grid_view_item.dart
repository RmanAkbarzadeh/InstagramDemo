import 'package:flutter/material.dart';
import 'package:instagram_demo/home_posts/posts_list.dart';
import 'package:instagram_demo/profile/profile_list_posts.dart';
import 'package:instagram_demo/res/images.dart';

class ProfileGridViewItem extends StatelessWidget {
  final String imageUrl;
  final PostFrom postFrom;
  final String anotherUserId;

  ProfileGridViewItem(this.imageUrl, this.postFrom,this.anotherUserId);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: FadeInImage(
          placeholder: AssetImage(InstagramImages.placeholder),
          fit: BoxFit.fill,
          image: NetworkImage(imageUrl)),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfilePostsList(postFrom,anotherUserId),
        ));
      },
    );
  }
}
