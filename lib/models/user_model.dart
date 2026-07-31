import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String name;
  String image;
  Timestamp date;
  String uid;

  UserModel({
    required this.email,
    required this.name,
    required this.image,
    required this.date,
    required this.uid,
  });

  factory UserModel.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      uid: data['uid'] ?? '',
    );
  }
}
