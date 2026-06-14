import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Figyeli a felhasználó bejelentkezési állapotának változását (Stream)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Aktuális felhasználó lekérése
  User? get currentUser => _firebaseAuth.currentUser;

  /// Bejelentkezés email és jelszó párossal
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Regisztráció email és jelszó párossal
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Kijelentkezés
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}