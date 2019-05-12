import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/auth_provider.dart';
import 'package:donatekuyv2/itemsbycategory.dart';
import 'package:flutter/material.dart';
import 'adddonation.dart';
import 'theme.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSignedOut;
  final String userId;
  HomePage({Key key, this.onSignedOut, this.userId}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _signOut() async {
    try {
      var auth = AuthProvider.of(context).auth;
      await auth.signOut();
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

  Row profileHeader(dynamic data) {
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
                  child: Image.network(
                    data['avatar'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 16,
              ),
              Text(
                data['firstName'],
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
                      MaterialPageRoute(builder: (context) => ProfilePage(profileId: widget.userId)),
                    );
                  },
                  child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document('${widget.userId}')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      if (snapshot.hasError)
                        return Text('Error!');
                      else if (snapshot.data == null)
                        return Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white),
                        );
                      else
                        return profileHeader(snapshot.data);
                    },
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Log out',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
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
            AspectRatio(
              aspectRatio: 16/9,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'images/carousel-0.jpg',
                    fit: BoxFit.cover,
                  )),
            ),
            SizedBox(height: 16),
            dividerWithText('Browse Categories'),
            SizedBox(height: 16),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('categories')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData || snapshot.data == null)
                  return CircularProgressIndicator();
                return ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: snapshot.data.documents.map((document) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                      child: Card(
                        elevation: 2.4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(
                            Icons.widgets,
                            color: Colors.grey,
                          ),
                          trailing: Icon(Icons.chevron_right),
                          title: Text(document['name']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ItemsByCategoryPage(category: document['name']))
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
