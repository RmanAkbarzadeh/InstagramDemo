import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/screens/profile_page.dart';

class UsersListItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String name;
  final String userId;
  UsersListItem({required this.imageUrl,required this.username,required this.name,required this.userId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed(ProfilePage.routeName,arguments: {
          "userId" : userId
        });
      },
      child: ListTile(
        leading: Container(width: 50,height: 50,child: CachedNetworkImage(
          imageBuilder: (context, imageProvider) => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          fit: BoxFit.cover,
          imageUrl: imageUrl,
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),),
        title: Text(username),
        subtitle: Text(name,style: TextStyle(color: Colors.grey,fontSize: 13),),
      ),
    );
  }
}
