import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Profile',
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Your Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                //TODO: implement edit profile
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => EditProfilePage(userData: widget.userData)),
                // );
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 26),
            StreamBuilder(
              stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    Container(
                      width: 130.0,
                      height: 130.0,
                      child: GestureDetector(
                        onTap: () {},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(65.0),
                          child: Image.network('${snapshot.data['avatar']}'),
                        ),
                      ),
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 4),
                            blurRadius: 4.0,
                          )
                        ],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 26),
                    Text(
                      '${snapshot.data['firstName']} ${snapshot.data['lastName']}',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 2),
                    FlatButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          //TODO: launch dialer
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.phone,
                              color: Colors.grey[700],
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              snapshot.data['phone'],
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: 20),
                    Text(
                      'Recent Donations',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    //TODO: recent donation with RecentItemVIew class
                    FlatButton(
                      child: Text('SEE ALL'),
                      onPressed: () {
                        //Navigator.push(
                        //  context,
                        //  MaterialPageRoute(builder: (context) => UserItemPage(userData: userData))
                        //);
                      },
                    ),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}