class ChatList {
  String text;
  String timestamp;
  String sender;

  ChatList({
    required this.text,
    required this.timestamp,
    required this.sender
  });
  
  factory ChatList.fromMap(Map<String, dynamic> map, String id) {
    return ChatList(
        sender: map['sender'] ?? '',
        text: map['text'] ?? '',
        timestamp: map['timestamp'] ?? '');
  }
}