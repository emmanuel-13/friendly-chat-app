// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user_model.dart';
import 'package:flutter_firebase/screens/auth_screen.dart';
import 'package:flutter_firebase/screens/home_screen.dart';
import 'package:flutter_firebase/screens/profile_screen.dart';
import 'package:flutter_firebase/screens/user_search.dart';
// import 'package:flutter_firebase/screens/login.dart';
import 'package:flutter_firebase/services/auth_service.dart';

// ignore: must_be_immutable
class BaseScreen extends StatefulWidget {
  UserModel user;
  BaseScreen({super.key, required this.user});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  List<Widget> screens = [];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    screens = [HomeScreen(data: widget.user), ProfileScreen(user: widget.user)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      appBar: AppBar(
        title: Text("Solution Chat"),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  showCloseIcon: true,
                  content: Text("Logged out successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.logout_sharp),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSearchScreen(user: widget.user),
            ),
          );
        },
        child: Icon(Icons.search_sharp),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
