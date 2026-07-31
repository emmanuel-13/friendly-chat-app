// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user_model.dart';
import 'package:flutter_firebase/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  UserModel data;
  HomeScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(data.uid)
          .collection("messages")
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data.docs.length < 1) {
          return Center(child: Text("No Messages"));
        }
        return ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            var friendId = snapshot.data.docs[index].id;
            var lastMsg = snapshot.data.docs[index]['last_msg'];
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(friendId)
                  .get(),
              builder: (context, AsyncSnapshot asyncSnapshot) {
                if (!asyncSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var friend = asyncSnapshot.data;
                return ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          currentUser: data,
                          friendId: friend["uid"],
                          friendImage: friend['image'],
                          friendName: friend['name'],
                        ),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: CachedNetworkImage(
                      imageUrl: friend['image'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.person),
                      height: 40,
                    ),
                  ),
                  title: Text(friend['name']),
                  subtitle: Text(
                    lastMsg,
                    style: TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
