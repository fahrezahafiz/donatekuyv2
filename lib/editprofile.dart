import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donatekuyv2/auth_provider.dart';
import 'package:donatekuyv2/theme.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);

  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String currUserId;
  String _fName, _lName, _phone;
  File image;
  String fileName;
  String _avatar;
  String imageUrl = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var auth = AuthProvider.of(context).auth;
    auth.currentUser().then((String userId) {
      // print('Current user: $userId');
      setState(() {
        currUserId = userId;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: myTheme(),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Edit Profile'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: submitEdit,
            ),
          ],
        ),
        body: FutureBuilder(
          future: Firestore.instance
              .collection('users')
              .document('$currUserId')
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null)
              return CircularProgressIndicator();
            _fName = snapshot.data['firstName'];
            _lName = snapshot.data['lastName'];
            _phone = snapshot.data['phone'];
            _avatar = snapshot.data['avatar'];
            return editForm(_fName, _lName, _phone, _avatar);
          },
        ),
      ),
    );
  }

  Widget editForm(String fName, String lName, String phone, String avatar) {
    return ListView(
      children: <Widget>[
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            avatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(Icons.arrow_forward, color: Colors.grey,),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _imagePickerDialog(context);
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]),
                          shape: BoxShape.circle
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Builder(builder: (context) {
                            if (image == null) {
                              return Center(
                                  child: IconButton(
                                icon: Icon(Icons.add_a_photo),
                                color: Colors.grey,
                                onPressed: () {
                                  _imagePickerDialog(context);
                                },
                              ));
                            } else {
                              return Stack(
                                fit: StackFit.passthrough,
                                children: <Widget>[
                                  Image.file(
                                    image,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          image = null;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                TextFormField(
                  initialValue: fName,
                  validator: (value) {
                    if (value.isEmpty) return 'Please enter your first name';
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
                  initialValue: lName,
                  validator: (value) {
                    if (value.isEmpty) return 'Please enter your last name';
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
                  initialValue: phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value.isEmpty) return 'Please enter your phone number';
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  _imagePickerDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Pick a source'),
            content: Container(
              width: 200,
              height: 100,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.image),
                    title: Text('Gallery'),
                    onTap: () {
                      getImageFromGallery(context);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.camera_alt),
                    title: Text('Camera'),
                    onTap: () {
                      getImageFromCamera(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future getImageFromGallery(BuildContext context) async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = selectedImage;
    });
    Navigator.pop(context);
  }

  Future getImageFromCamera(BuildContext context) async {
    var selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = selectedImage;
      fileName = 'avatar_$currUserId';
    });
    Navigator.pop(context);
  }

  Future uploadImage() async {
    fileName = 'avatar_$currUserId';
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('avatar/$fileName');
    final StorageUploadTask task = firebaseStorageRef.putFile(image);

    String getUrl = await (await task.onComplete).ref.getDownloadURL();
    setState(() {
      imageUrl = getUrl;
    });
  }

  Future<void> submitEdit() async {
    final _form = _formKey.currentState;
    if (_form.validate()) {
      _form.save();
      try {
        var auth = AuthProvider.of(context).auth;
        await uploadImage().then((_) {
          auth.editProfile(_fName, _lName, _phone, imageUrl).then((value) {
            Navigator.pop(context);
          });
        });
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
}
