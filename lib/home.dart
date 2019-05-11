import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'adddonation.dart';
import 'auth.dart';
import 'theme.dart';
import 'login.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  HomePage({Key key, this.auth, this.onSignedOut}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<Null> _getUserDetails() async {
    FirebaseUser currUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = currUser;
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(dynamic e) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
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

  Row profileHeader(AsyncSnapshot<dynamic> snapshot) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 64,
                height: 64,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network('${snapshot.data['avatar']}'),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                snapshot.data['firstName'],
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainDrawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 180,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: myTheme().primaryColor,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(-2, 4),
                    blurRadius: 6.0,
                  )
                ],
              ),
              padding: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.hasError)
                        return Text('Error!');
                      else if (snapshot.data == null)
                        return Text('Loading...');
                      else
                        return profileHeader(snapshot);
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildDrawerTile('Your Donation', context, LoginPage()),
          _buildDrawerTile('Q&A', context, LoginPage()),
          _buildDrawerTile('Settings', context, LoginPage()),
          _buildDrawerTile('About', context, LoginPage()),
          ListTile(
            title: Text(
              'Log out',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );

    Widget dividerWithText(String value) {
      return Row(
        children: <Widget>[
          Expanded(
              child: Divider(
            color: Colors.grey[600],
          )),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text('$value', style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
              child: Divider(
            color: Colors.grey[600],
          )),
        ],
      );
    }

    return MaterialApp(
      title: 'DonateKuy',
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('DonateKuy'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
            Builder(builder: (context) {
              return IconButton(
                tooltip: 'Add Donation',
                icon: Icon(Icons.add_box),
                onPressed: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddDonationPage()));
                  if (result != null) {
                    Scaffold.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('$result')));
                  }
                },
              );
            }),
          ],
        ),
        drawer: mainDrawer,
        body: ListView(
          children: <Widget>[
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('images/carousel-0.jpg')),
            SizedBox(height: 20),
            dividerWithText('Browse Categories'),
            SizedBox(height: 20),
            Center(),
            //TODO: category grid
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerTile(String label, BuildContext context, Widget page) {
    return ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            color: myTheme().primaryColor,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        });
  }
}
