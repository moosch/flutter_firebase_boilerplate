import 'package:flutter/material.dart';

import 'package:firebase_auth_boilerplate/locator.dart';
import 'package:firebase_auth_boilerplate/core/services/user/user.dart';
import 'package:firebase_auth_boilerplate/views/login/login_enums.dart';
import 'package:firebase_auth_boilerplate/core/helpers/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserService userService = locator<UserService>();

  final TextEditingController _controller = TextEditingController();

  final formKey = GlobalKey<FormState>();
  String _displayName, _email, _password;
  bool _loading = false;
  FormType _formType = FormType.Login;

  bool validate() {
    final form = formKey.currentState;
    form.save();

    return form.validate() ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.1, 1],
            colors: [
              Color.fromARGB(255, 118, 235, 227),
              Color.fromARGB(255, 131, 106, 236),
            ],
          ),
        ),
        child: Center(
          child: Form(
          key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ...(
                  buildInputs() + buildButtons()
                ),
                if (_loading == true)
                  CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    List<Widget> _fields = [];
    if (_formType == FormType.Register) {
      _fields = _fields + [
        TextFormField(
          maxLines: 1,
          validator: DisplayNameValidator.validate,
          decoration: InputDecoration(labelText: "Name"),
          onSaved: (_value) => _displayName = _value.trim(),
        ),
      ];
    }

    return _fields + [
      TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        validator: EmailValidator.validate,
        decoration: InputDecoration(labelText: "Email"),
        onChanged: (_value) => _email = _value.trim(),
      ),
      TextFormField(
        validator: PasswordValidator.validate,
        decoration: InputDecoration(labelText: "Password"),
        obscureText: true,
        onChanged: (_value) => _password = _value.trim(),
      ),
    ];
  }

  List<Widget> buildButtons() {
    if (_formType == FormType.Login) {
      return [
        RaisedButton(
          child: Text("Login"),
          onPressed: () => submit(),
        ),
        FlatButton(
          child: Text("Register"),
          onPressed: () {
            switchFormState('register');
          },
        ),
        FlatButton(
          child: Text("Login with Google"),
          onPressed: () async {
            _loading = true;
            await userService.signInWithGoogle();
            _loading = false;
          },
        ),
      ];
    } else {
      return [
        RaisedButton(
          child: Text("Create Account"),
          onPressed: () => submit(),
        ),
        FlatButton(
          child: Text("Login"),
          onPressed: () {
            switchFormState('login');
          },
        ),
      ];
    }
  }

  void switchFormState(String state) {
    formKey.currentState.reset();

    switch (state) {
      case 'register':
        setState(() {
          _formType = FormType.Register;
        });
        break;
      case 'login':
        setState(() {
          _formType = FormType.Login;
        });
        break;
      default:
    }
  }

  void submit() async {
    if (validate()) {
      switch (_formType) {
        case FormType.Login:
          _loading = true;
          await userService.signInWithEmailAndPassword(_email, _password);
          _loading = false;
          break;
        case FormType.Register:
          _loading = true;
          await userService.createUserWithEmailAndPasswrod(_displayName, _email, _password);
          _loading = false;
          break;
      }
    }
  }
}
