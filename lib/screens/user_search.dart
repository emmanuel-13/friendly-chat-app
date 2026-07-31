import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/models/user_model.dart';
import 'package:flutter_firebase/screens/chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final UserModel user;
  const UserSearchScreen({super.key, required this.user});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map> searchResults = [];
  bool loading = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchUser() async {
    setState(() {
      searchResults.clear();
      loading = true;
    });

    await FirebaseFirestore.instance
        .collection("users")
        .where("name", isEqualTo: searchController.text)
        .get()
        .then((value) {
          if (value.docs.isEmpty) {
            if (!mounted) {
              return;
            }
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("User not found")));
            setState(() {
              loading = false;
            });
            return;
          } else {
            for (var user in value.docs) {
              if (user.data()["uid"] == widget.user.uid) {
                continue;
              }
              searchResults.add(user.data());
              setState(() {
                loading = false;
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Users"),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search...",
                      labelText: "Search Users",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    controller: searchController,
                  ),
                ),
              ),
              GestureDetector(
                onTap: searchUser,
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ],
          ),
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        searchResults[index]["image"],
                      ),
                    ),
                    title: Text(searchResults[index]["name"]),
                    subtitle: Text(searchResults[index]["email"]),
                    trailing: IconButton(
                      icon: Icon(Icons.message_rounded),
                      onPressed: () {
                        setState(() {
                          searchController.text = "";
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatScreen(
                                currentUser: widget.user,
                                friendId: searchResults[index]['uid'],
                                friendImage: searchResults[index]['image'],
                                friendName: searchResults[index]['name'],
                              );
                            },
                          ),
                        );
                      },
                    ),
                    onTap: () {},
                  );
                },
              ),
            )
          else if (searchResults.isEmpty && loading == false)
            Expanded(child: Center(child: Text("No users found")))
          else if (loading == true)
            Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
