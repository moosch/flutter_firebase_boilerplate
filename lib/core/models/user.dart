import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  static const uidField = 'uid';
  static const displayNameField = 'displayName';
  static const emailField = 'email';
  static const providerField = 'provider';
  static const lastSeenField = 'lastSeen';

  String uid;
  String email;
  Timestamp lastSeen;
  String displayName;
  String provider;

  User(this.lastSeen);

  User.initial()
    : email = '',
      displayName = '';

  User.fromFirestore(Map<String, dynamic> doc) {
    this.uid = doc["uid"];
    this.email = doc["email"];
    this.lastSeen = doc["lastSeen"];
    this.displayName = doc["displayName"];
    this.provider = doc["provider"];
  }

  User.fromFirebaseUser(FirebaseUser user) {
    this.uid = user.uid;
    this.email = user.email;
    this.displayName = user.displayName;
    this.lastSeen = Timestamp.now();
    this.provider = user.providerId;
  }

  Map<String, dynamic> toJson() {
    return {
      "email": this.email,
      "displayName": this.displayName,
      "lastSeen": this.lastSeen ?? Timestamp.now(),
      "provider": this.provider,
    };
  }

  @override
  String toString() {
    return 'uid: $uid, email: $email, displayName: $displayName, lastSeen: $lastSeen';
  }
}
