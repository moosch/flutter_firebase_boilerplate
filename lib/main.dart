import 'package:flutter/material.dart';

import 'package:firebase_auth_boilerplate/locator.dart';
import 'package:firebase_auth_boilerplate/router.dart';
import 'package:firebase_auth_boilerplate/views/auth_wrapper.dart';

void main() {
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      onGenerateRoute: Router.generateRoute,
      home: AuthWrapper(),
    );
  }
}
