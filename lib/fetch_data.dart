import 'package:cloud_firestore/cloud_firestore.dart';

class FetchData{
  String _photoImage = "";
  String _username = "";


  String get username => _username;

  String get photoImage => _photoImage;

  Future<void> fetchData(String userId) async{
    String url = "";
    String name = "";
    await FirebaseFirestore.instance
          .collection("users")
          .where("userId", isEqualTo: userId)
          .get().then((doc) {
            url = doc.docs[0].data()["profileImage"];
            name = doc.docs[0].data()["username"];
    });
    _photoImage = url;
    _username = name;
  }

}