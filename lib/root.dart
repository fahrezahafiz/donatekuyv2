import 'package:donatekuyv2/auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';
import 'auth.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;
  RootPage({Key key, this.auth}) : super(key: key);

  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId){
      setState(() {
       authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
     authStatus = AuthStatus.signedIn; 
    });
  }

  void _signedOut() {
    setState(() {
     authStatus = AuthStatus.notSignedIn; 
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        print('No current user. Redirecting to login page...');
        return LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        print('User retrieved. Redirecting to home page...');
        return HomePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
        );
    }
  }
}