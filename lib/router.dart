import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:firebase_auth_boilerplate/views/home/home.dart';
import 'package:firebase_auth_boilerplate/views/login/login.dart';

const String initialRoute = "login";

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case 'login':
        return MaterialPageRoute(builder: (_) => LoginScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('404! How did you get here? There is no route defined for ${settings.name}'),
            ),
          ));
    }
  }
}
