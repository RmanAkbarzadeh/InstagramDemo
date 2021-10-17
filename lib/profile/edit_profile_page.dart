
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_demo/models/user.dart';
import 'package:instagram_demo/profile/add_image_to_profile.dart';
import 'package:provider/provider.dart';

import '../get_profile_image.dart';

class EditProfilePage extends StatefulWidget {
  static const String routeName = "/edit-profile-page";

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  bool _isLoading= false;

  bool _updateData = true;

@override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
  if(_updateData) {
    final argument = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;
    final name = argument["name"];
    final bio = argument["bio"];
    _nameController.text = name;
    _bioController.text = bio;
    super.didChangeDependencies();
  }
  _updateData = false;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit Profile"),
        actions: [IconButton(onPressed: () {
          Navigator.of(context).pop();
        }, icon: Icon(Icons.check))],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (context) {
                return AddImageToProfile();
              },);
            },
            child: GetProfileImage(user!.uid,90,"",false),
          ),
          SizedBox(
            height: 30,
          ),
            Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(hintText: "Name"),
              controller: _nameController,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(hintText: "Bio"),
              controller: _bioController,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          if(!_isLoading)
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: deviceSize.width * 0.7),
              child: ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _isLoading = true;
                    });
                    Provider.of<AppUsers>(context,listen: false).updateProfile(_nameController, _bioController, context);
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Text("Update Profile"),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey),foregroundColor: MaterialStateProperty.all<Color>(Colors.black) ))),
          SizedBox(
            height: 5,
          ),
          if(_isLoading)
            Center(child: CircularProgressIndicator()),
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
            },
            child: Text("Logout"),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).errorColor)),
          ),
        ],
      ),
    );
  }
}
