import 'package:flutter/foundation.dart';

class AuthService {
  // Mock authentication - no Firebase
  Future<bool> login(String email, String password) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      // Mock validation - accept any non-empty credentials
      return email.isNotEmpty && password.isNotEmpty;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String email, String password, String displayName) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));
      // Mock validation - accept any non-empty credentials
      return email.isNotEmpty && password.isNotEmpty && displayName.isNotEmpty;
    } catch (e) {
      debugPrint('Signup error: $e');
      return false;
    }
  }

  Future<bool> biometricLogin() async {
    // Placeholder for biometric authentication
    debugPrint('Biometric login - UI only mode');
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }
}
