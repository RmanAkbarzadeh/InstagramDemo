import 'package:flutter/material.dart';
import 'package:instagram_demo/res/images.dart';
import 'package:instagram_demo/adding_post/adding_post_dialog.dart';

class AddingPostPage extends StatelessWidget {
  const AddingPostPage({Key? key}) : super(key: key);
  static const String routeName = "/adding-post-page";


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
            InstagramImages.adding_post_image,
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
                      return AddingPostDialog();
                    },);
                  },
                  label: Text("Add a post")))
        ],
      ),
    ));
  }
}
