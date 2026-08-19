import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String email, String password, {String? displayName});
  Future<UserEntity> signInAnonymously();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  static const String _guestModeKey = 'is_guest_session';

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        return _mapFirebaseUser(user);
      }
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool(_guestModeKey) ?? false;
      if (isGuest) {
        return const UserEntity(
          id: 'guest_user',
          displayName: 'Guest User',
          isAnonymous: true,
        );
      }
      return null;
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _mapFirebaseUser(user);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool(_guestModeKey) ?? false;
      if (isGuest) {
        return const UserEntity(
          id: 'guest_user',
          displayName: 'Guest User',
          isAnonymous: true,
        );
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const ServerException('Authentication failed. No user returned.');
      }
      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to sign in: $e');
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const ServerException('Registration failed. No user returned.');
      }
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }
      return _mapFirebaseUser(_firebaseAuth.currentUser ?? user)!;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create account: $e');
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);

      final credential = await _firebaseAuth.signInAnonymously();
      final user = credential.user;
      if (user != null) {
        return _mapFirebaseUser(user)!;
      }
    } catch (e) {
      // Fallback for offline guest session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      return const UserEntity(
        id: 'guest_user',
        displayName: 'Guest User',
        isAnonymous: true,
      );
    }
    return const UserEntity(
      id: 'guest_user',
      displayName: 'Guest User',
      isAnonymous: true,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: $e');
    }
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName ?? (user.isAnonymous ? 'Guest User' : user.email?.split('@').first),
      isAnonymous: user.isAnonymous,
      createdAt: user.metadata.creationTime,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    final code = e.code.toLowerCase();
    final message = (e.message ?? '').toLowerCase();

    if (code == 'user-not-found' || message.contains('user not found') || message.contains('no user record')) {
      return 'No account found with this email. Please sign up.';
    } else if (code == 'wrong-password') {
      return 'Incorrect password. Please try again.';
    } else if (code == 'invalid-credential' ||
        code == 'invalid_login_credentials' ||
        message.contains('auth credential') ||
        message.contains('credential is incorrect')) {
      return 'Incorrect email or password. Please check your credentials or sign up.';
    } else if (code == 'email-already-in-use' || message.contains('already in use')) {
      return 'An account already exists for this email. Please sign in instead.';
    } else if (code == 'invalid-email') {
      return 'Please enter a valid email address.';
    } else if (code == 'weak-password') {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (code == 'operation-not-allowed') {
      return 'Email/Password sign-in is not enabled in Firebase Console.';
    } else if (code == 'user-disabled') {
      return 'This account has been disabled. Please contact support.';
    } else if (code == 'too-many-requests') {
      return 'Too many attempts. Please wait a moment and try again.';
    } else if (code == 'network-request-failed' || message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return e.message ?? 'Authentication error ($code).';
  }
}
