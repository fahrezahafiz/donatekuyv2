import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/profile.dart';
import 'package:donatekuyv2/staticprofile.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemPage extends StatefulWidget {
  final String docID;
  const ItemPage({Key key, this.docID}) : super(key: key);

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  String _userId = '',
      _category = '',
      _delivMethod = '',
      _description = '',
      _imageUrl = '',
      _condition = '',
      _name = '',
      _quantity = '',
      _userName = '',
      _email = '',
      _phone = '',
      _location = '',
      _avatar = '';
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  Future<void> getDetails() async {
    DocumentSnapshot item = await Firestore.instance
        .collection('items')
        .document(widget.docID)
        .get();
    setState(() {
      _userId = item['userId'];
      _category = item['category'];
      _delivMethod = item['delivMethod'];
      _description = item['description'];
      _imageUrl = item['imageUrl'];
      _condition = item['itemCondition'];
      _name = item['name'];
      _quantity = item['quantity'];
      _isAvailable = item['isAvailable'];
    });
    DocumentSnapshot user =
        await Firestore.instance.collection('users').document(_userId).get();
    setState(() {
      _avatar = user['avatar'];
      _userName = '${user['firstName']} ${user['lastName']}';
      _email = user['email'];
      _phone = user['phone'];
      _location = user['location'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(
                    background: GestureDetector(
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ImageDetail(imageUrl: _imageUrl)),
                      ),
                  child: Hero(
                    tag: 'itemImageHero',
                    child: Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
              ),
            ];
          },
          body: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        decoration: BoxDecoration(
                          color: _isAvailable ? Colors.green[400]: Colors.red[400],
                          borderRadius: BorderRadius.circular(8)
                        ),
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Center(
                          child: Text(
                            _isAvailable
                                ? 'This item is still available'
                                : 'This item is no longer available.',
                            style: TextStyle(
                              color: _isAvailable ? Colors.white: Colors.red[100]
                            ),
                          ),
                        )),
                    SizedBox(height: 16),
                    Text(_name,
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      _category,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 14),
                    FlatButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StaticProfilePage(profileId: _userId,))
                      ),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(_avatar),
                          ),
                          SizedBox(width: 10),
                          Text('$_userName in $_location',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey[600],
                                  fontSize: 14))
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              _condition,
                              style:
                                  TextStyle(fontSize: 24, color: Colors.green),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'KONDISI',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              _quantity,
                              style:
                                  TextStyle(fontSize: 24, color: Colors.green),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'PCS',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              _delivMethod,
                              style:
                                  TextStyle(fontSize: 24, color: Colors.green),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'METODE',
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Text('Deskripsi', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                    Text(
                      _description,
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ],
          )),
      bottomSheet: contactSheet(),
    );
  }

  Widget contactSheet() {
    return Container(
      height: 60,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 2,
        )
      ]),
      child: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              onPressed: () => launch("mailto:$_email"),
              child: Row(
                children: <Widget>[
                  Icon(Icons.mail, color: Colors.green),
                  SizedBox(width: 10),
                  Text('EMAIL', style: TextStyle(color: Colors.grey[600]))
                ],
              ),
            ),
            VerticalDivider(),
            FlatButton(
              onPressed: () => launch("tel://$_phone"),
              child: Row(
                children: <Widget>[
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 10),
                  Text('PHONE', style: TextStyle(color: Colors.grey[600]))
                ],
              ),
            )
          ],
        ),
      ),
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
            tag: 'itemImageHero',
            child: Image.network(
              '$imageUrl',
              fit: BoxFit.cover,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
