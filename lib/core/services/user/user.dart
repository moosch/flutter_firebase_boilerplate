import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_auth_boilerplate/locator.dart';
import 'package:firebase_auth_boilerplate/core/services/firebase/firebase_auth.dart';
import 'package:firebase_auth_boilerplate/core/services/firestore/firestore.dart';
import 'package:firebase_auth_boilerplate/core/models/user.dart';
import 'package:firebase_auth_boilerplate/core/services/firebase/auth_constants.dart';

abstract class BaseUserService {
  Stream<User> get onAuthStateChanged;
  Future<FirebaseUser> currentUser();
  Future<void> createUserWithEmailAndPasswrod(String displayName, String email, String password);
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> updateUserLastSeen();
  Future<void> signOut();
  Future<void> checkLoggedIn();
}

class UserService implements BaseUserService {
  UserService() {
    _setup();
  }

  final FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  final FirestoreUserService _fireStoreUserService = locator<FirestoreUserService>();
  StreamSubscription<User> _firebaseAuthSubscription;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
      // 'profile',
      // 'openid',
    ],
  );

  /*
  Registers a Firebase auth subscriber which is then used
  as a User stream  
  */
  void _setup() {
    _firebaseAuthSubscription =
      _firebaseAuthService.onAuthStateChanged.listen((User user) {
        _onAuthStateChangedController.add(user);
      }, onError: (dynamic error) {
        _onAuthStateChangedController.addError(error);
      });
  }

  final StreamController<User> _onAuthStateChangedController =
      StreamController<User>.broadcast();

  @override
  Stream<User> get onAuthStateChanged => _onAuthStateChangedController.stream;

  void dispose() {
    _firebaseAuthSubscription?.cancel();
    _onAuthStateChangedController?.close();
  }

  @override
  Future<FirebaseUser> currentUser() async {
    return (await _firebaseAuth.currentUser());
  }

  @override
  Future<void> createUserWithEmailAndPasswrod(String displayName, String email, String password) async {
    try {
      FirebaseUser firebaseUser = await _firebaseAuthService.createUserWithEmailAndPassword(
        email,
        password,
      );

      User _user = User.fromFirebaseUser(firebaseUser);

      // Dirty update
      _user.displayName = displayName;
      await _fireStoreUserService.createUser(_user);
    } catch(error) {

    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser firebaseUser;

    try {
      firebaseUser = await _firebaseAuthService.signInWithEmailAndPassword(email, password);

      await _findOrCreateUser(firebaseUser: firebaseUser);
    } catch (error) {
      print(error);
      throw(error);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      FirebaseUser firebaseUser = await _firebaseAuthService.signInWithGoogle();
      await _findOrCreateUser(firebaseUser: firebaseUser);
    } catch (error) {
      print(error);
      throw(error);
    }
  }

  @override
  Future<void> updateUserLastSeen() async {
    await _fireStoreUserService.updateLastSeen();
  }

  @override
  Future<void> signOut() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    User user = User.fromFirebaseUser(firebaseUser);
    if (user.provider == AuthProviders.google) {
      await _googleSignIn.signOut();
    }

    FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> checkLoggedIn() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    if (firebaseUser != null && firebaseUser?.uid != null) {
      Map<String, dynamic> _fireStoreUser = await _fireStoreUserService.findByUID(firebaseUser.uid);

      User _user = User.fromFirestore(_fireStoreUser);

      if (_user != null) {
        await updateUserLastSeen();
      }
    }
  }

  Future<User> _findOrCreateUser({ FirebaseUser firebaseUser, String displayName }) async {
    User _user;
    Map<String, dynamic> fireStoreUser;

    if (firebaseUser == null) {
      firebaseUser = await _firebaseAuthService.currentUser();
    }

    try {
      fireStoreUser = await _fireStoreUserService.findOrCreate(firebaseUser, AuthProviders.emailPassword);
      _user = User.fromFirestore(fireStoreUser);

      await updateUserLastSeen();

      if (displayName != null) {
        _user.displayName = displayName;
        _user = await _fireStoreUserService.updateDisplayName(displayName);
      }

      return _user;
    } catch (error) {
      print(error);
      throw(error);
    }
  }
}
