import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:demo_application/models/user.dart' as app_user;
import 'package:demo_application/services/firebase_utils.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String usersCollection = 'users';

  // Get current user
  User? get currentFirebaseUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<app_user.User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Get FCM token
        final fcmToken = await _messaging.getToken() ?? '';
        
        // Create or update user document
        final appUser = app_user.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Unknown',
          avatar: firebaseUser.photoURL ?? 'https://via.placeholder.com/150',
          fcmToken: fcmToken,
          isOnline: true,
          lastSeen: DateTime.now(),
        );

        // Save to Firestore with merge to create if doesn't exist
        await FirebaseUtils.createDocumentWithRetry(
          _firestore.collection(usersCollection).doc(firebaseUser.uid),
          appUser.toJson(),
        );

        return appUser;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Update user offline status
      if (_auth.currentUser != null) {
        await FirebaseUtils.safeDocumentUpdate(
          _firestore.collection(usersCollection).doc(_auth.currentUser!.uid),
          {
            'isOnline': false,
            'lastSeen': Timestamp.now(),
          },
        );
      }

      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user data
  Future<app_user.User?> getCurrentUserData() async {
    if (_auth.currentUser == null) return null;

    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(_auth.currentUser!.uid)
          .get();

      if (doc.exists) {
        return app_user.User.fromJson(doc.data()!);
      }
    } catch (e) {
      print('Error getting current user data: $e');
    }
    return null;
  }

  // Update user online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (_auth.currentUser == null) return;

    try {
      // Use FirebaseUtils for safe document update
      await FirebaseUtils.safeDocumentUpdate(
        _firestore.collection(usersCollection).doc(_auth.currentUser!.uid),
        {
          'isOnline': isOnline,
          'lastSeen': Timestamp.now(),
        },
      );
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
