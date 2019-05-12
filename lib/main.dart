import 'package:donatekuyv2/auth_provider.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'root.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: MaterialApp(
        home: RootPage(),
      ),
    );
  }
}
