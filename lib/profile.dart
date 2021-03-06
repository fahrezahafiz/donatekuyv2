import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/item.dart';
import 'editprofile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;
  ProfilePage({Key key, this.profileId}) : super(key: key);

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Profile',
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Your Profile'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 26),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.profileId)
                  .snapshots(),
              builder: (context, snapshot) {
                dynamic data = snapshot.data;
                if (!snapshot.hasData || data == null)
                  return CircularProgressIndicator();
                return ProfileSection(data: data);
              },
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Donations',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 8),
            StreamBuilder(
              stream: Firestore.instance
                  .collection('items')
                  .where('userId', isEqualTo: widget.profileId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
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
                          leading: Image.network(
                            document['imageUrl'],
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                          ),
                          title: Text(document['name']),
                          subtitle: Text(document['addedAt'].toString()),
                          trailing: itemMenu(document.documentID),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ItemPage(docID: document.documentID))
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget itemMenu(String docId) {
    return PopupMenuButton<String>(
      onSelected: (String option){
        executeOption(option, docId);
      },
      itemBuilder: (context){
        return ItemAction.options.map((String option){
          return PopupMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList();
      },
    );
  }

  Future<void> executeOption(String option, String docId) async{
    switch (option) {
      case ItemAction.markAsDone:
        await Firestore.instance.collection('items').document(docId).updateData({
          "isAvailable": false
        });
        break;
      case ItemAction.unmarkAsDone:
        await Firestore.instance.collection('items').document(docId).updateData({
          "isAvailable": true
        });
        break;
      case ItemAction.delete:
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete item'),
            content: Text('Are you sure?'),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),FlatButton(
                child: Text('Yes'),
                onPressed: () async {
                  await Firestore.instance.collection('items').document(docId).delete().then((_){
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
        break;
    }
  }
}

class ProfileSection extends StatelessWidget {
  final dynamic data;
  const ProfileSection({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ImageDetail(imageUrl: data['avatar'])));
          },
          child: Hero(
            tag: 'avatarHero',
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x40000000),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                )
              ], shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(65),
                child: Image.network(
                  '${data['avatar']}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          '${data['firstName']} ${data['lastName']}',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                launch("mailto:${data['email']}");
              },
              child: Column(
                children: <Widget>[
                  SizedBox(
                      height: 42,
                      child:
                          Icon(Icons.mail, size: 32, color: Colors.green)),
                  Text('EMAIL', style: TextStyle(color: Colors.grey[700]))
                ],
              ),
            ),
            SizedBox(width: 30),
            InkWell(
              onTap: () {
                launch("tel://${data['phone']}");
              },
              child: Column(
                children: <Widget>[
                  SizedBox(
                      height: 42,
                      child:
                          Icon(Icons.phone, size: 32, color: Colors.green)),
                  Text('PHONE', style: TextStyle(color: Colors.grey[700]))
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImageDetail extends StatelessWidget {
  final String imageUrl;
  ImageDetail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'avatarHero',
            child: Image.network('$imageUrl'),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ItemAction {
  static const String markAsDone = 'Mark as done';
  static const String unmarkAsDone = 'Unmark as done';
  static const String delete = 'Delete';

  static const List<String> options = <String> [
    markAsDone,
    unmarkAsDone,
    delete
  ];
}
