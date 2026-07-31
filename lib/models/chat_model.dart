class ChatModel {
  String? id;
  String? name;
  String? message;
  String? time;
  String? avatar;

  ChatModel({this.id, this.name, this.message, this.time, this.avatar});

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      message: json['message'] as String?,
      time: json['time'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}
