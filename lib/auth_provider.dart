import 'package:donatekuyv2/auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends InheritedWidget {
  AuthProvider({Key key, this.child, this.auth}) : super(key: key, child: child);

  final Widget child;
  final BaseAuth auth;

  static AuthProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AuthProvider) as AuthProvider);
  }

  @override
  bool updateShouldNotify( AuthProvider oldWidget) {
    return true;
  }
}