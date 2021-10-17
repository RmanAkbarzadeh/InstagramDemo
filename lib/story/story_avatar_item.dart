import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/fetch_data.dart';
import 'package:instagram_demo/story/story_screen.dart';

class StoryAvatarItem extends StatefulWidget {
  final String userId;
  StoryAvatarItem(this.userId);

  @override
  _StoryAvatarItemState createState() => _StoryAvatarItemState();
}

class _StoryAvatarItemState extends State<StoryAvatarItem> {
  FetchData fetchData = FetchData();
  bool _isLoading = false;


  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    _isLoading = true;
    fetchData.fetchData(widget.userId).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false ? GestureDetector(
      child: Column(
      children: [
        CachedNetworkImage(
          placeholder: (context, url) => Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: AssetImage("assets/images/sample_profile_image.png"), fit: BoxFit.cover),
      ),
    ),
        imageBuilder: (context, imageProvider) => Container(
        width: 70,
        height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: imageProvider, fit: BoxFit.cover),
      ),
    ),
    fit: BoxFit.cover,
    imageUrl: fetchData.photoImage,
    errorWidget: (context, url, error) => Icon(Icons.error),
    ),
        SizedBox(height: 3,),
        Text(fetchData.username,style: TextStyle(fontSize: 12,),)
      ],
    ),
      onTap: (){
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoryScreen(widget.userId),));
    },) : Center();
  }
}
