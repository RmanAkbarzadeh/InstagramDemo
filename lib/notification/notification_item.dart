import 'package:flutter/material.dart';
import 'package:instagram_demo/get_profile_image.dart';

class NotificationItem extends StatelessWidget {
  final String userId;
  final String userName;
  final String description;
  final String imageUrl;

  NotificationItem(this.userId,this.userName,this.description,this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(width : 45,height: 40,child: GetProfileImage(userId, 50, "", false)),
          title: Text(userName,style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(description,style: TextStyle(color: Colors.grey),),
          trailing:imageUrl=="noImage" ? null : Container(width: 50,height: 50,child: Image.network(imageUrl,fit: BoxFit.fill,),),
        ),
        Divider(height: 1,color: Colors.grey,)
      ],
    );
  }
}
