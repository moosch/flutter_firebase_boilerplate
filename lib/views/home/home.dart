import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:firebase_auth_boilerplate/locator.dart';
import 'package:firebase_auth_boilerplate/core/services/user/user.dart';
import 'package:firebase_auth_boilerplate/core/models/user.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserService auth = locator<UserService>();
    final user = Provider.of<User>(context);

    String displayName = user.displayName != null ? user.displayName : "buddy!";

    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Column(
            children: <Widget>[
              Text("Welcome $displayName!"),
            ],
          ),
        ),
      ),
    );
  }
}