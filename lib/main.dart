import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user_model.dart';
import 'package:flutter_firebase/screens/auth_screen.dart';
import 'package:flutter_firebase/screens/base.dart';
// import 'package:flutter_firebase/screens/base.dart';
// import 'package:flutter_firebase/screens/login.dart';
// import 'package:flutter_firebase/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await GoogleSignIn.instance.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> userSignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      UserModel userModel = UserModel.fromJson(userData);
      return BaseScreen(user: userModel);
    } else {
      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Firebase",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: userSignedIn(),
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),

      // StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     }
      //     if (snapshot.hasData) {
      //       return Scaffold(
      //         body: BaseScreen(userName: snapshot.data!.displayName),
      //       );
      //     } else {
      //       return const Scaffold(body: AuthScreen());
      //     }
      //   },
      // ),

      // StreamBuilder(
      //   stream: AuthService().firebaseAuth.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return Scaffold(body: Center(child: CircularProgressIndicator()));
      //     }
      //     if (snapshot.hasData) {
      //       return Scaffold(
      //         body: BaseScreen(userName: snapshot.data!.displayName),
      //       );
      //     } else {
      //       return Scaffold(body: LoginScreen());
      //     }
      //   },
      // ),
    );
  }
}
