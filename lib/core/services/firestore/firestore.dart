import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth_boilerplate/core/services/firestore/firestore_constants.dart';
import 'package:firebase_auth_boilerplate/core/models/user.dart';

abstract class BaseUserFirebase {
  Future<void> createUser(User user);
  Future<Map<String, dynamic>> findOrCreate(
    FirebaseUser firebaseUser,
    String provider,
  );
  Future<void> updateLastSeen();
  Future<Stream<DocumentSnapshot>> getUserStream();
  Future<User> updateDisplayName(String displayName);
  Future<Map<String, dynamic>> findByUID(String uid);
}

class FirestoreUserService implements BaseUserFirebase {
  @override
  Future<void> createUser(User user) async {
    final firebaseUser = await FirebaseAuth.instance.currentUser();

    final userReference = Firestore.instance
      .collection(FirestoreConstants.userCollection)
      .document(firebaseUser.uid);

    try {
      await userReference.setData(user.toJson());
    } catch (error) {
      print(error);
      throw error;
    }
  }

  @override
  Future<Map<String, dynamic>> findOrCreate(FirebaseUser firebaseUser, String provider) async {
    final userReference = Firestore.instance
      .collection(FirestoreConstants.userCollection)
      .document(firebaseUser.uid);

    DocumentSnapshot userDocumentSnapshot = await userReference.get();
    if (userDocumentSnapshot.exists == false) {
      try {
        // Create Firestore user
        User user = User.fromFirebaseUser(firebaseUser);
        await userReference.setData(user.toJson());

        // Refetch by furebaseUser.uid
        userDocumentSnapshot = await userReference.get();

        return userDocumentSnapshot.data;
      } catch (error) {
        print(error);
        throw error;
      }
    }

    return userDocumentSnapshot.data;
  }

  @override
  Future<void> updateLastSeen() async {
    final firebaseUser = await FirebaseAuth.instance.currentUser();
    Map<String, dynamic> update = Map();
    update.putIfAbsent(User.lastSeenField, () => Timestamp.now());

    try {
      await Firestore.instance.collection(FirestoreConstants.userCollection)
        .document(firebaseUser.uid)
        .updateData(update);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  Future<Stream<DocumentSnapshot>> getUserStream() async {
    final firebaseUser = await FirebaseAuth.instance.currentUser();
    final userDocumentStream = Firestore.instance
      .collection(FirestoreConstants.userCollection)
      .document(firebaseUser.uid)
      .snapshots();
    return userDocumentStream;
  }

  @override
  Future<User> updateDisplayName(String displayName) async {
    final firebaseUser = await FirebaseAuth.instance.currentUser();

    await Firestore.instance
      .collection(FirestoreConstants.userCollection)
      .document(firebaseUser.uid)
      .updateData({ "displayName": displayName });

    User user = User.fromFirebaseUser(firebaseUser);
    // Dirty update
    user.displayName = displayName;
    return user;
  }

  @override
  Future<Map<String, dynamic>> findByUID(String uid) async {
    final userReference = Firestore.instance
      .collection(FirestoreConstants.userCollection)
      .document(uid);

    DocumentSnapshot userDocumentSnapshot = await userReference.get();

    if (userDocumentSnapshot.exists != false) {
      return userDocumentSnapshot.data;
    }

    return null;
  }
}
