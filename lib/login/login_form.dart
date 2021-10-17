import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class LoginForm extends StatefulWidget {
  bool isSignUp ;
  Function _trySubmitAuth;
  LoginForm(this.isSignUp,this._trySubmitAuth);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";

  String _userName = "";

  String _password = "";

  void _trySubmit() {
    final _isValid = _formKey.currentState!.validate();

    if (_isValid) {
      _formKey.currentState!.save();
      widget._trySubmitAuth(_email.trim(), _userName.trim(), _password.trim(), widget.isSignUp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
        child: Column(
      children: [
        Container(
          width: deviceSize.width * 0.6,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1))),
            validator: (value) {
              if (value == null || !value.contains("@")) {
                return "PLease enter a valid email .";
              }
              return null;
            },
            onSaved: (value) {
              _email = value as String;
            },
          ),
        ),
        SizedBox(
          height: 5,
        ),
        if(widget.isSignUp)
          Container(
            padding: EdgeInsets.only(bottom: 5),
            width: deviceSize.width * 0.6,
            child: TextFormField(
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  labelText: "Username",
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1))),
              validator: (value) {
                if (value == null || value.length < 5) {
                  return "PLease enter a valid username..";
                }
                return null;
              },
              onSaved: (value) {
                _userName = value as String;
              },
            ),
          ),
        Container(
          width: deviceSize.width * 0.6,
          child: TextFormField(
            style: TextStyle(color: Colors.black),
            obscureText: true,
            decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1))),
            validator: (value) {
              if (value == null || value.length < 7) {
                return "PLease enter a valid password. .";
              }
              return null;
            },
            onSaved: (value) {
              _password = value as String;
            },
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ElevatedButton(
          onPressed: _trySubmit,
          child: widget.isSignUp ? Text(
            "Sign up",
            style: TextStyle(fontSize: 17),
          ) : Text(
            "Log in",
            style: TextStyle(fontSize: 17),
          ),
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(
                  Size(deviceSize.width * 0.6, 40))),
        ),
        SizedBox(
          height: 30,
        ),
        if(!widget.isSignUp)
        TextButton(
            onPressed: () {},
            child: Text(
              "Forgot password ?",
              style: TextStyle(fontSize: 17),
            )),
      ],
    ));
  }
}
