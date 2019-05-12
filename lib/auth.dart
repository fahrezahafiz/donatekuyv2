import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password, String fName, String lName, String phone, String location, String avatar);
  Future<String> currentUser();
  Future<void> signOut();
  Future<void> editProfile(String fName, String lName, String phone, String imageUrl);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    FirebaseUser user = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return user?.uid;
  }

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String fName, String lName, String phone, String location, String avatar) async {
    FirebaseUser user = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    await Firestore.instance.collection('users').document(user.uid).setData({
      "firstName": fName,
      "lastName": lName,
      "email": user.email,
      "phone": phone,
      "location": location,
      "avatar": avatar,
    });
    return user?.uid;
  }

  @override
  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> editProfile(String fName, String lName, String phone, String imageUrl) async {
    String userId = await currentUser();
    await Firestore.instance.collection('users').document('$userId').updateData({
      "firstName": fName,
      "lastName": lName,
      "phone": phone,
      "avatar": imageUrl,
    });
    print('New name: $fName $lName. New phone: $phone');
  }
}

