import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/Widget/message_text.dart';
import 'package:flutter_firebase/Widget/single_message.dart';
import 'package:flutter_firebase/models/user_model.dart';

class ChatScreen extends StatelessWidget {
  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;
  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.friendId,
    required this.friendImage,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: friendImage,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.person),
                height: 40,
              ),
            ),
            SizedBox(width: 10.0),
            Text(
              friendName,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(currentUser.uid)
                    .collection("messages")
                    .doc(friendId)
                    .collection("chats")
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.docs.length < 1) {
                      return Center(child: Text("Say hi to begin a chat"));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        bool isMe =
                            snapshot.data.docs[index]['senderId'] ==
                            currentUser.uid;
                        return SingleMessage(
                          message: snapshot.data.docs[index]['message'],
                          isMe: isMe,
                        );
                      },
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          MessageText(currentUserId: currentUser.uid, friendId: friendId),
        ],
      ),
    );
  }
}
