import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth_boilerplate/locator.dart';
import 'package:firebase_auth_boilerplate/core/models/user.dart';
import 'package:firebase_auth_boilerplate/core/services/user/user.dart';
import 'package:firebase_auth_boilerplate/views/home/home.dart';
import 'package:firebase_auth_boilerplate/views/login/login.dart';

class AuthWrapper extends StatelessWidget {
  final UserService userService = locator<UserService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: userService.onAuthStateChanged,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        final User user = snapshot.data;

        if (user != null) {
          return Provider<User>(
            create: (_) => user,
            child: HomeScreen(),
          );
        }

        return LoginScreen();
      },
    );
  }
}