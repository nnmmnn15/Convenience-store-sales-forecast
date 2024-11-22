class ChatRoom {
  String id;
  String imagePath;
  String roomName;

  ChatRoom({required this.id, required this.imagePath, required this.roomName});
  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
        id: map['id'] ?? '',
        imagePath: map['image'],
        roomName: map['roomname']);
  }
}
