class ChatRoom {
  String id;
  String imagePath;
  ChatRoom({
    required this.id,
    required this.imagePath
  });
  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: map['id'] ?? '',
      imagePath: map['image']
    );
  }
}