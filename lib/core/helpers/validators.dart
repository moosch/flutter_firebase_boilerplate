class DisplayNameValidator {
  static String validate(String value) {
    return value.isEmpty? "Your name must be added" : null;
  }
}

class EmailValidator {
  static String validate(String value) {
    return value.isEmpty? "Email must be added" : null;
  }
}

class PasswordValidator {
  static String validate(String value) {
    return value.isEmpty? "Password must be added" : null;
  }
}
