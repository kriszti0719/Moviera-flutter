import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/user_model.dart';
import '../services/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository({required FirebaseAuthService authService}) : _authService = authService;

  /// Stream konvertálása: Firebase User -> Biztonságos domain UserModel
  Stream<UserModel?> get onAuthStateChanged {
    return _authService.authStateChanges.map((User? user) {
      if (user == null) return null;
      return UserModel.fromFirebase(user.uid, user.email ?? '');
    });
  }

  /// Bejelentkezés és konverzió
  Future<UserModel> login(String email, String password) async {
    final credential = await _authService.signInWithEmail(email, password);
    final user = credential.user!;
    return UserModel.fromFirebase(user.uid, user.email ?? '');
  }

  /// Regisztráció és konverzió
  Future<UserModel> register(String email, String password) async {
    final credential = await _authService.signUpWithEmail(email, password);
    final user = credential.user!;
    return UserModel.fromFirebase(user.uid, user.email ?? '');
  }

  /// Kijelentkezés
  Future<void> logout() async {
    await _authService.signOut();
  }
}