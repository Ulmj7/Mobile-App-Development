import 'package:flutter/foundation.dart';

/// Demo-only, in-memory authentication. There is no server: any well-formed
/// e-mail signs in with the current password, and nothing is persisted.
class AuthService extends ChangeNotifier {
  /// The first password of every session (lab 4, task 2 #1).
  static const defaultPassword = 'Mobile317';

  bool _loggedIn = false;
  String _email = '';
  String _password = defaultPassword;

  bool get loggedIn => _loggedIn;
  String get email => _email;

  Future<bool> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (password != _password) return false;
    _email = email.trim();
    _loggedIn = true;
    notifyListeners();
    return true;
  }

  /// Returns false when [current] is not the current password.
  Future<bool> changePassword(String current, String next) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (current != _password) return false;
    _password = next;
    return true;
  }

  void logout() {
    _loggedIn = false;
    _email = '';
    notifyListeners();
  }

  /// Back to a signed-out session with the default password. Only
  /// [resetAppState] calls this.
  void reset({bool loggedIn = false, String email = 'test@example.com'}) {
    _password = defaultPassword;
    _loggedIn = loggedIn;
    _email = loggedIn ? email : '';
    notifyListeners();
  }
}

final auth = AuthService();
