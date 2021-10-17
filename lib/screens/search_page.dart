import 'package:flutter/material.dart';
import 'package:instagram_demo/screens/home_page.dart';
import 'package:instagram_demo/search/load_all_users.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const String routeName = "/search-page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () {
        Navigator.of(context).pushReplacementNamed(HomePage.routeName);
      }, icon: Icon(Icons.arrow_back)), title: TextField(
        decoration: InputDecoration(
            hintText: "Search"
        ),
      ),),
      body: Column(
        children: [
          SizedBox(height: 5,),
          Expanded(child: SingleChildScrollView(child: Container(height : MediaQuery.of(context).size.height*0.8,child: LoadAllUsers())))
        ],
      ),
    );
  }
}
