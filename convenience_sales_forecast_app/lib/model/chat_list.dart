class ChatList {
  String text;
  String timestamp;
  String sender;
  String roomId;

  ChatList({
    required this.text,
    required this.timestamp,
    required this.sender,
    required this.roomId,
  });

  factory ChatList.fromMap(Map<String, dynamic> map, String roomId) {
    return ChatList(
      text: map['text'] ?? '',
      timestamp: map['timestamp'] ?? '',
      sender: map['sender'] ?? '',
      roomId: roomId, // 방 ID 저장
    );
  }
}
