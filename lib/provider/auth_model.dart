import 'dart:math';

import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  Future<bool> login() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network request for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random success or failure
    final success = Random().nextBool();

    if (success) {
      _isLoggedIn = true;
    }
    // If it fails, _isLoggedIn remains false.

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
