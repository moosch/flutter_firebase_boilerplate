import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_auth_boilerplate/core/models/user.dart';
import 'package:firebase_auth_boilerplate/core/services/firebase/auth_constants.dart';

abstract class BaseFirebaseAuth {
  Stream<User> get onAuthStateChanged;
  Future<FirebaseUser> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<FirebaseUser> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<FirebaseUser> currentUser();
  Future<void> signOut();
  Future<FirebaseUser> signInWithGoogle();
}

class FirebaseAuthService implements BaseFirebaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      // 'profile',
      // 'openid',
    ],
  );

  // StreamController<User> userController = StreamController<User>();

  Future<FirebaseUser> currentUser() async {
    return (await _firebaseAuth.currentUser());
  }

  @override
  Stream<User> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
    (FirebaseUser user) => User.fromFirebaseUser(user),
  );

  // auth change user stream
  Stream<User> get user {
    return _firebaseAuth.onAuthStateChanged
      .map((user) => User.fromFirebaseUser(user));
  }

  @override
  Future<FirebaseUser> createUserWithEmailAndPassword(String email, String password) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    assert(!result.user.isAnonymous);
    assert(await result.user.getIdToken() != null);

    return result.user;
  }

  @override
  Future<FirebaseUser> signInWithEmailAndPassword(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    assert(!result.user.isAnonymous);
    assert(await result.user.getIdToken() != null);

    return result.user;
  }

  @override
  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _auth = await account.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: _auth.accessToken,
      idToken: _auth.idToken,
    );

    AuthResult result = await _firebaseAuth.signInWithCredential(credential);
    FirebaseUser user = result.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    return user;
  }

  @override
  Future<void> signOut() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    User user = User.fromFirebaseUser(firebaseUser);
    if (user.provider == AuthProviders.google) {
      await _googleSignIn.signOut();
    }

    return FirebaseAuth.instance.signOut();
  }
}
