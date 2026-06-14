import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel({required AuthRepository authRepository}) : _authRepository = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Hibaüzenet törlése (pl. amikor a felhasználó elkezd gépelni egy új mezőbe)
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Bejelentkezés kezelése hiba- és töltésvezérléssel
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Please fill in all fields.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? "Authentication failed.";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred.";
      notifyListeners();
      return false;
    }
  }

  /// Regisztráció kezelése hiba- és töltésvezérléssel
  Future<bool> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Please fill in all fields.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? "Registration failed.";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred.";
      notifyListeners();
      return false;
    }
  }

  /// Kijelentkezés kezelése
  Future<void> logout() async {
    await _authRepository.logout();
  }
}