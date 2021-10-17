import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:instagram_demo/res/images.dart';
import 'package:instagram_demo/login/login_form.dart';
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = FirebaseAuth.instance;
  var _isLoading = false;
  bool isSignUp = false;

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void _trySubmitAuth(
    String email,
    String userName,
    String password,
    bool isSignUp,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential userCredential;
      if (!isSignUp) {
        userCredential = await auth.signInWithEmailAndPassword(
            email: email, password: password);
        String? token = await FirebaseMessaging.instance.getToken();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .update({
          "token" : token as String,
        });

      } else {
        userCredential = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
        String? token = await FirebaseMessaging.instance.getToken();
        print(token);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "username": userName,
          "email": email,
          "bio": "Add a bio !",
          "name": "Pick a name for yourself !",
          "userId": userCredential.user!.uid,
          "token" : token as String,
          "followers": [],
          "following": [],
          "profileImage":
              "https://firebasestorage.googleapis.com/v0/b/instagram-project-65893.appspot.com/o/user_posts_images%2Fsample_profile_image.png?alt=media&token=e651def5-dae6-46e6-9ee8-28fe4fb08c59"
        });

        await FirebaseFirestore.instance
            .collection("direct")
            .doc(userCredential.user!.uid)
            .set({
          "chatList" : []
        });

        await FirebaseFirestore.instance
            .collection("stories")
            .doc(userCredential.user!.uid)
            .set({
          "storiesList" : [],
          "userId" : userCredential.user!.uid
        });
      }
    } on FirebaseAuthException catch (error) {
      var message = "Something went wrong !";
      if (error.message != null) {
        message = error.message as String;
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: deviceSize.height * 0.15,
                    ),
                    Image.asset(
                      InstagramImages.instagram_black_logo,
                      height: 90,
                      width: deviceSize.width * 0.6,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.facebook),
                      onPressed: () {},
                      label: Text(
                        "Continue with Facebook",
                        style: TextStyle(fontSize: 17),
                      ),
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all<Size>(
                            Size(deviceSize.width * 0.6, 40)),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "OR",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (!_isLoading) LoginForm(isSignUp, _trySubmitAuth),
                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(),
                      )
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 70,
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSignUp)
                    Text(
                      "I have an account ?",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  if (!isSignUp)
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          isSignUp = !isSignUp;
                        });
                      },
                      child: !isSignUp
                          ? Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Color.fromRGBO(5, 15, 82, 1.0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            )
                          : Text(
                              "Log in",
                              style: TextStyle(
                                  color: Color.fromRGBO(5, 15, 82, 1.0),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
