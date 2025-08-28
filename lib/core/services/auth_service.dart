import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user document if it doesn't exist
      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'householdId': null,
      });
    }
  }

  Future<String> updateUserProfilePicture(File imageFile) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    try {
      // Process and compress image
      final base64Image = await _processProfileImageToBase64(imageFile);
      
      // Create data URL for storage - smaller size for better performance
      final dataURL = 'data:image/jpeg;base64,$base64Image';
      
      // Update Firestore user document with base64 - this is our primary source
      await _updateUserDocument(user.uid, {
        'customProfilePicture': base64Image, // Primary storage for profile picture
        'photoURL': dataURL, // Backup reference
      });
      
      // Don't update Firebase Auth photoURL with data URL as it has size limitations
      // Instead, we'll use the Firestore data directly in the UI
      
      return dataURL;
    } catch (e) {
      throw Exception('Failed to update profile picture: ${e.toString()}');
    }
  }

  Future<String> _processProfileImageToBase64(File imageFile) async {
    try {
      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Invalid image file');
      }

      // Create a square crop from the center to avoid distortion
      final size = image.width < image.height ? image.width : image.height;
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;
      final cropped = img.copyCrop(image, x: x, y: y, width: size, height: size);
      
      // Resize to 200x200 and compress more for smaller base64 storage
      final resized = img.copyResize(cropped, width: 200, height: 200);
      final processedBytes = img.encodeJpg(resized, quality: 75);
      
      // Convert to base64
      final base64Image = base64Encode(processedBytes);
      
      return base64Image;
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  Future<String?> getUserProfilePictureUrl() async {
    final user = currentUser;
    if (user == null) return null;
    
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      
      // Return custom profile picture URL if available, otherwise return Firebase Auth photoURL
      return data?['photoURL'] as String? ?? user.photoURL;
    } catch (e) {
      // Fallback to Firebase Auth profile picture
      return user.photoURL;
    }
  }

  Future<void> _updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user document: ${e.toString()}');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'internal-error':
        return 'Internal error occurred. Please try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}