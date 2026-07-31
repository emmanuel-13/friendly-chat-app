import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  UserModel? user;
  ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  "https://www.freepnglogos.com/uploads/facebook-messenger-png/facebook-messenger-customer-chat-icons-and-png-12.png",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  height: 40,
                  width: 40,
                  child: IconButton(
                    icon: Icon(Icons.update_rounded),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          Text(
            user!.name,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            user!.email,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
