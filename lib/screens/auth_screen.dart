// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/main.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool loading = false;

  Future<User?> signinwithGoogle(BuildContext context) async {
    try {
      // triggering the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // obtain the accesstoken
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(["email", "profile"]);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization?.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      DocumentSnapshot userExist = await firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userExist.exists) {
        await firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .update({
              "name": userCredential.user!.displayName,
              "email": userCredential.user!.email,
              "image": userCredential.user!.photoURL,
              "uid": userCredential.user!.uid,
              "date": DateTime.now(),
            });
        print(
          "User ${userCredential.user!.displayName} already exists in Firestore",
        );
      } else {
        await firestore.collection("users").doc(userCredential.user!.uid).set({
          "name": userCredential.user!.displayName,
          "email": userCredential.user!.email,
          "image": userCredential.user!.photoURL,
          "uid": userCredential.user!.uid,
          "date": DateTime.now(),
        });
      }
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      "https://www.freepnglogos.com/uploads/facebook-messenger-png/facebook-messenger-customer-chat-icons-and-png-12.png",
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Text(
              "Flutter Chat App",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0,
              ),
              child: loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        User? user = await signinwithGoogle(context);
                        setState(() {
                          loading = false;
                        });
                        if (user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              showCloseIcon: true,
                              dismissDirection: DismissDirection.up,
                              backgroundColor: Colors.green,
                              content: Text("Signed in as ${user.displayName}"),
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => MainApp()),
                          );
                        } else {
                          // Add feedback here so you know when sign-in fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              showCloseIcon: true,
                              dismissDirection: DismissDirection.up,
                              backgroundColor: Colors.red,
                              content: Text("Sign-in failed or was canceled."),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.black),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 20.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-suite-everything-you-need-know-about-google-newest-0.png",
                            height: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Sign in with Google",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
