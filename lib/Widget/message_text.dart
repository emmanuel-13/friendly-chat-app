import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageText extends StatefulWidget {
  final String? currentUserId;
  final String? friendId;
  const MessageText({super.key, this.currentUserId, this.friendId});

  @override
  State<MessageText> createState() => _MessageTextState();
}

class _MessageTextState extends State<MessageText> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: "Enter message",
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 0),
                  gapPadding: 10,
                ),
              ),
            ),
          ),
          // IconButton(icon: const Icon(Icons.send), onPressed: () {}),
          SizedBox(width: 10.0),
          GestureDetector(
            onTap: () async {
              String message = textController.text.trim();
              if (message.isEmpty) return; // Don't send blank messages
              textController.clear();
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.currentUserId)
                  .collection("messages")
                  .doc(widget.friendId)
                  .collection("chats")
                  .add({
                    "message": message,
                    "senderId": widget.currentUserId,
                    "receiverId": widget.friendId,
                    "time": DateTime.now(),
                    "type": "text",
                  })
                  .then(((value) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.currentUserId)
                        .collection("messages")
                        .doc(widget.friendId)
                        .set({"last_msg": message});
                  }));

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.friendId)
                  .collection("messages")
                  .doc(widget.currentUserId)
                  .collection("chats")
                  .add({
                    "message": message,
                    "senderId": widget.currentUserId,
                    "receiverId": widget.friendId,
                    "time": DateTime.now(),
                    "type": "text",
                  })
                  .then((value) {
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(widget.friendId)
                        .collection("messages")
                        .doc(widget.currentUserId)
                        .set({"last_msg": message});
                  });
            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
