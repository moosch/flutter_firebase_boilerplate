import 'package:get_it/get_it.dart';

import 'package:firebase_auth_boilerplate/core/services/firebase/firebase_auth.dart';
import 'package:firebase_auth_boilerplate/core/services/firestore/firestore.dart';
import 'package:firebase_auth_boilerplate/core/services/user/user.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FirestoreUserService());
  locator.registerLazySingleton(() => UserService());
}
