/*
author: 이원영
Description: view/chat.dart에 사용될 chat collection handler
Fixed: 11/20
Usage: 채팅 기능 구현
*/
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/chat_list.dart';
import 'package:convenience_sales_forecast_app/model/chat_room.dart';
import 'package:convenience_sales_forecast_app/model/users.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatHandler extends UserHandler {
  final chats = <ChatList>[].obs;
  final rooms = <ChatRoom>[].obs;
  final lastChats = <ChatList>[].obs;
  ScrollController listViewContoller = ScrollController();
  RxBool chatShow = false.obs;
  RxString currentRoomId = 'Anam'.obs;
  RxDouble opacity = 1.0.obs;
  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('chat');
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      queryLastChat(rooms);
    });
  }

  @override
  void onInit() async {
    super.onInit();
    getAllData();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel(); // 타이머 종료
    super.onClose();
  }
  getAllData() async {
    await makeChatRoom();
    await queryChat(currentRoomId.value);
    update();
  }

  setcurrentRoomId(String roomid) {
    currentRoomId.value = roomid;
    update();
  }

  showChat() async {
    chatShow.value = true;
    opacity.value = 0.25;
    update();
  }

  String? getUserImageByEmail(List<Users> users, String email) {
    // users 리스트에서 email이 일치하는 항목 찾기
    final matchedUser = users.firstWhere(
      (user) => user.email == email,
      orElse: () => Users(email: '', image: '', name: ''), // 기본값 설정
    );
    return matchedUser.image.isNotEmpty ? matchedUser.image : null;
  }


  String? getUserNameByEmail(List<Users> users, String email) {
    final matchedUser = users.firstWhere(
      (user) => user.email == email,
      orElse: () => Users(email: '', image: '', name: ''), // 기본값 설정
    );
    return matchedUser.name.isNotEmpty ? matchedUser.name : null;
  }


  queryChat(String room) async{
    _rooms
        .doc(room) 
        .snapshots() 
        .listen((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        List<dynamic> messages = docSnapshot.get('chats') ?? [];
        List<ChatList> mappedMessages = messages
            .map((message) => ChatList.fromMap(message as Map<String, dynamic>, room))
            .toList();
        mappedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        chats.value = mappedMessages;
      } else {
        chats.clear();
      }
    });
  }

  queryLastChat(List<ChatRoom> rooms) async {
    for (int i = 0; i < rooms.length; i++) {
    _rooms
        .doc(rooms[i].id)
        .snapshots()
        .listen((DocumentSnapshot docSnapshot) {
      if (docSnapshot.exists) {
        List<dynamic> messages = docSnapshot.get('chats') ?? [];
        if (messages.isNotEmpty) {
          Map<String, dynamic> lastMessage = messages.last as Map<String, dynamic>;
          ChatList chat = ChatList.fromMap(lastMessage, rooms[i].id);
          int existingIndex = lastChats.indexWhere((c) => c.roomId == rooms[i].id);
          if (existingIndex != -1) {
            lastChats[existingIndex] = chat;
          } else {
            lastChats.add(chat);
          }
        }
      } else {
        lastChats.removeWhere((c) => c.roomId == rooms[i].id);
      }
    });
     }
    update();
  }

  makeChatRoom() async {
    _rooms.snapshots().listen((event) {
      rooms.value = event.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ChatRoom(
          id: doc.id,
          imagePath: data['image'] ?? "", 
        );
      }).toList();
    });
    update();
  }

  isToday() async {
    bool istoday = true;
    chats[chats.length - 1].timestamp.toString().substring(0, 10) ==
            DateTime.now().toString().substring(0, 10)
        ? istoday
        : istoday = false;
    return istoday;
  }

  checkToday(ChatList chat) {
    return chat.text.length == 17 &&
        chat.text.substring(0, 3) == "set" &&
        chat.text.substring(13, 17) == "time";
  }

  addChat(ChatList chat) async {
    bool istoday = await isToday();
    if (!istoday) {
      await _rooms.doc("$currentRoomId").update({'chats':FieldValue.arrayUnion([
      {'sender': chat.sender,
      'text': chat.text,
      'timestamp': DateTime.now().toString()}
    ])});
    }
    _rooms
      .doc("$currentRoomId").update({'chats':FieldValue.arrayUnion([
      {'sender': chat.sender,
      'text': chat.text,
      'timestamp': DateTime.now().toString()}
    ])});
  }
}

