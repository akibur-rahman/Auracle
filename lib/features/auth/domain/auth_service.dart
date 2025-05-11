import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;

  @override
  Stream<User?> build() {
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    return _auth.authStateChanges();
  }

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => currentUser != null;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getMessageFromErrorCode(e.code));
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  Future<UserCredential> createUserWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(username);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getMessageFromErrorCode(e.code));
    } catch (e) {
      throw AuthException('Failed to create account: $e');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw AuthException('Sign in was aborted');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getMessageFromErrorCode(e.code));
    } catch (e) {
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'network-request-failed':
        return 'A network error occurred. Check your connection.';
      default:
        return 'An error occurred: $errorCode';
    }
  }
}
