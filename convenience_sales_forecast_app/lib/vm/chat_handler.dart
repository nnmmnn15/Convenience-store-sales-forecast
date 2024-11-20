import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/chat_list.dart';
import 'package:convenience_sales_forecast_app/model/chat_room.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
class ChatHandler extends UserHandler {
  final chats = <ChatList>[].obs;
  final rooms = <ChatRoom>[].obs;
  ScrollController listViewContoller = ScrollController();
  RxBool chatShow = false.obs;
  RxString currentRoomId = ''.obs;
  final CollectionReference _rooms =
      FirebaseFirestore.instance.collection('chat');
 


  getAllData() async {
    await makeChatRoom();
    // await queryLastChat();
    // await queryChat();
    // await getlastName();
    update();
  }

  setcurrentRoomId(String roomid) {
    currentRoomId.value = roomid;
    update();
  }

  showChat() async {
    chatShow.value = true;
    update();
  }

  queryChat(String room) async{
    FirebaseFirestore.instance
        .collection('chat') // chat 컬렉션
        .doc(room) // 특정 문서 ID
        .snapshots() // 실시간 스냅샷
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
        print("Document does not exist!");
      }
    });
  }


  queryLastChat() async {
    List<ChatList> returnResult = [];
    if(returnResult.isNotEmpty){
      returnResult.clear();
    }
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("chat")
        .where('clinic', isEqualTo: Get.find<UserHandler>().box.read('id'))
        .get();
    var tempresult = snapshot.docs.map((doc) => doc.data()).toList();
    // for (int i = 0; i < tempresult.length; i++) {
    //   ChatRoom chatroom = ChatRoom(
    //       id: _rooms.doc().id);
    //   // result.add(chatroom);
    // }
    // for (int i = 0; i < result.length; i++) {
    //   _rooms
    //       .doc(
    //         // "${Get.find<UserHandler>().box.read('id')}_${result[i].user}"
    //       )
    //       .collection('chats')
    //       .orderBy('timestamp', descending: true)
    //       .limit(1)
    //       .snapshots()
    //       .listen(
    //     (event) {
    //       for (int i = 0; i < event.docs.length; i++) {
    //         var chat = event.docs[i].data();
    //         returnResult.add(ChatList(
    //             sender: chat['sender'],
    //             text: chat['text'],
    //             timestamp: chat['timestamp']));
    //       }
    //       // lastChats.value = returnResult;
    //     },
    //   );
    // }
    update();
  }
  makeChatRoom() async {
    _rooms.snapshots().listen((event) {
      rooms.value = event.docs.map((doc) {
        // 문서 데이터 가져오기
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return ChatRoom(
          id: doc.id,
          imagePath: data['image'] ?? "", // image 필드 값 가져오기
        );
      }).toList();
    });
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

