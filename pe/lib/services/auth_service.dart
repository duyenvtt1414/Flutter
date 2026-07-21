import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { staff, manager }

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  UserRole roleForEmail(String? email) {
    final normalized = email?.toLowerCase() ?? '';
    return normalized.contains('manager') ? UserRole.manager : UserRole.staff;
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
