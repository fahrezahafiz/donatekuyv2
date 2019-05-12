import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/item.dart';
import 'package:donatekuyv2/theme.dart';
import 'package:flutter/material.dart';

class ItemsByCategoryPage extends StatelessWidget {
  final String category;
  const ItemsByCategoryPage({Key key, this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(category),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance
                  .collection('items')
                  .where('category', isEqualTo: category)
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                if (snapshot.data == null)
                  return Text('No item in this category');
                return ListView(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: snapshot.data.documents.map<Widget>((document) {
                    return ItemCard(document: document);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  final dynamic document;
  const ItemCard({Key key, this.document}) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  String userLoc = '';

  @override
  void initState() {
    super.initState();
    getUserLoc();
  }

  void getUserLoc() async {
    DocumentSnapshot user = await Firestore.instance.collection('users').document(widget.document['userId']).get();
    setState(() {
     userLoc = user['location']; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // print('${widget.document.documentID} selected');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItemPage(docID: widget.document.documentID))
        );
      },
      child: AspectRatio(
        aspectRatio: 2.4,
        child: Container(
            margin: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 2.4,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.network(
                        widget.document['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.document['name'],
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Row(children: <Widget>[
                            Icon(
                              Icons.info,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8),
                            Text(
                              widget.document['isAvailable'] ? 'Available': 'Unavailable',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ]),
                          SizedBox(height: 8),
                          Row(children: <Widget>[
                            Icon(
                              Icons.confirmation_number,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${widget.document['quantity']} pcs',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ]),
                          SizedBox(height: 8),
                          Row(children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 8),
                            Text(
                              userLoc,
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
