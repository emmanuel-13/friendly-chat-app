// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // function to register user
  Future<User?> register(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "The password provided is too weak, ${e.message.toString()}",
            ),
          ),
        );
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "The account already exists for that email., ${e.message.toString()}",
            ),
          ),
        );
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      print(e.toString());
      return null;
    }
  }

  // function to login
  Future<User?> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No user found for that email., ${e.message.toString()}",
            ),
          ),
        );
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Wrong password provided for that user., ${e.message.toString()}",
            ),
          ),
        );
        print('Wrong password provided for that user.');
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      print(e.toString());
      return null;
    }
  }

  // google sign in functionality
  Future<User?> siginwithGoogle() async {
    try {
      // 1. Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      // Handle user cancellation
      if (googleUser == null) {
        print("Google sign-in was canceled by the user.");
        return null;
      }

      // 2. Await the authentication details (Future!)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 3. Obtain authorization tokens (Access Token required by Firebase)
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);

      // 4. Create the Firebase credential using BOTH tokens
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: authorization?.accessToken,
      );

      // 5. Sign in to Firebase
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future signOut() async {
    await GoogleSignIn.instance.signOut();
    await firebaseAuth.signOut();
  }
}
