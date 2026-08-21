import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth. Guests get an anonymous account
/// automatically; email/password sign-up lets them keep the same account
/// (and its data) across devices.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _injectedAuth = firebaseAuth;

  // Resolved lazily (rather than in the constructor) so that constructing
  // an AuthService doesn't require Firebase to already be initialized --
  // useful for widget tests that never touch auth.
  final FirebaseAuth? _injectedAuth;
  FirebaseAuth get _firebaseAuth => _injectedAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  bool get isGuest => currentUser != null && currentUser!.isAnonymous;

  /// Called on app start. If nobody is signed in yet, starts an anonymous
  /// (guest) session so the app is usable immediately, with no signup step.
  Future<void> ensureSignedIn() async {
    if (_firebaseAuth.currentUser == null) {
      await _firebaseAuth.signInAnonymously();
    }
  }

  /// Upgrades the current guest session to a full account, so the guest's
  /// existing data (once there is any) carries over instead of being lost.
  Future<void> signUpWithEmail(String email, String password) async {
    final guest = _firebaseAuth.currentUser;
    if (guest != null && guest.isAnonymous) {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await guest.linkWithCredential(credential);
    } else {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // Immediately start a fresh guest session -- the app requires a signed
    // in user (even an anonymous one) to function.
    await ensureSignedIn();
  }
}
