import 'package:donatekuyv2/auth_provider.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

class RootPage extends StatefulWidget {

  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  notDetermined,
  notSignedIn,
  signedIn
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notDetermined;
  String currUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId){
      setState(() {
        if (userId == null){
          authStatus = AuthStatus.notSignedIn;
        } else {
          currUserId = userId;
          authStatus = AuthStatus.signedIn;
        }
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
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();
      case AuthStatus.notSignedIn:
        print('No current user. Redirecting to login page...');
        return LoginPage(
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        print('UID $currUserId retrieved. Redirecting to home page...');
        return HomePage(
          userId: currUserId,
          onSignedOut: _signedOut,
        );
    }
    return null;
  }
  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}