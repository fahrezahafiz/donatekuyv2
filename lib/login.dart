import 'package:donatekuyv2/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'home.dart';
import 'register.dart';
import 'theme.dart';

class LoginPage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  LoginPage({Key key, this.auth, this.onSignedIn}) : super(key: key);

  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _password;
  String loginMsg = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myTheme(),
      title: 'Login Page',
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 150.0,
                bottom: 50,
              ),
              child: SizedBox(
                height: 60.0,
                child: Image.asset(
                  'images/logo-text.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter an email';
                      },
                      onSaved: (value) => _email = value,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a password';
                        if (value.length < 5)
                          return 'Password must be at least 8 characters';
                      },
                      onSaved: (value) => _password = value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: 40.0,
                        child: Center(
                          child: Text(
                            '$loginMsg',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.red[400],
                            ),
                          ),
                        )),
                    InkWell(
                      child: ButtonTheme(
                        minWidth: 300,
                        height: 48.0,
                        child: RaisedButton(
                          onPressed: signIn,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0)),
                          child: Text(
                            'LOG IN',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          color: myTheme().primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Builder(
                      builder: (context) {
                        return FlatButton(
                          onPressed: () {
                            _navToRegister(context);
                          },
                          child: Text(
                            'Sign up for a new account',
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    final _form = _formKey.currentState;
    if (_form.validate()) {
      _form.save();
      try {
        String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
        print('Signed in: $userId');
        widget.onSignedIn();
      } catch (e) {
        setState(() {
          loginMsg = e.message;
        });
      }
    }
  }

  _navToRegister(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage(auth: Auth())),
    );
    if (result != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$result')));
    }
  }
}