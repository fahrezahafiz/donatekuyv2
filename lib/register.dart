import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/auth_provider.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _fName, _lName, _email, _password, _phone, _location;
  final String _avatar =
      'https://firebasestorage.googleapis.com/v0/b/donatekuy.appspot.com/o/default-avatar.png?alt=media&token=33861c61-c627-4fe1-98a6-4ba0e1e9f935';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up',
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sign Up'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 40.0),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter your name';
                      },
                      onSaved: (value) => _fName = value,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter your name';
                      },
                      onSaved: (value) => _lName = value,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter your email';
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
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter your password';
                        if (value.length < 5)
                          return 'Password must be more than 5 characters.';
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
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value.isEmpty)
                          return 'Please enter your phone number';
                      },
                      onSaved: (value) => _phone = value,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        contentPadding: EdgeInsets.all(16.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('location')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Text('Loading...');
                        List<DropdownMenuItem> locations = [];
                        for (int i = 0;
                            i < snapshot.data.documents.length;
                            i++) {
                          DocumentSnapshot snap = snapshot.data.documents[i];
                          locations.add(DropdownMenuItem(
                            child: Text(snap['name']),
                            value: snap['name'],
                          ));
                        }
                        return InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(16, 3, 16, 3),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            labelText: 'Location',
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: locations,
                              onChanged: (value) {
                                setState(() {
                                  _location = value;
                                });
                              },
                              value: _location,
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 40)),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: signUp,
          icon: Icon(Icons.check),
          label: Text('Sign Up'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Future<void> signUp() async {
    final _form = _formKey.currentState;
    if (_form.validate()) {
      _form.save();
      try {
        var auth = AuthProvider.of(context).auth;
        String userId = await auth.createUserWithEmailAndPassword(
            _email, _password, _fName, _lName, _phone, _location, _avatar);
        print('Registered user: $userId');
        Navigator.pop(context, 'Register success!');
      } catch (e) {
        print(e.message);
        _showError(e);
        _form.reset();
      }
    }
  }

  void _showError(dynamic e) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Register error'),
            content: Text(e.message),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
