/*
author: 이원영
Description: 채팅 ui
Fixed: 11/20
Usage: 점주들 그룹 채팅
*/
import 'package:convenience_sales_forecast_app/model/chat_list.dart';
import 'package:convenience_sales_forecast_app/model/chat_room.dart';
import 'package:convenience_sales_forecast_app/vm/chat_handler.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';


class Chat extends StatelessWidget {
  Chat({super.key});
  final ChatHandler chatsHandler = Get.put(ChatHandler());
  final userHandler = Get.find<UserHandler>();
  final TextEditingController chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder(
        future: chatsHandler.getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('오류 발생: ${snapshot.error}'),
            );
          } else {
            return Obx(() => chatRoomList(context));
          }
        },
      ),
    );
  }

  Widget chatRoomList(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: chatsHandler.rooms.length,
              itemBuilder: (context, index) {
                ChatRoom room = chatsHandler.rooms[index];
                return GestureDetector(
                  onTap: () async {
                    await chatsHandler.setcurrentRoomId(room.id);
                    await chatsHandler.setcurrentRoomName(room.roomName);
                    await chatsHandler.queryChat(chatsHandler.currentRoomId.value);
                    await chatsHandler.showChat(index);
                  },
                  child: Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 12.0
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height/9,
                        child: Card(
                          color: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                              color: chatsHandler.selectedChatIndex.value == index
                              ? Colors.blue // 선택된 항목의 테두리 색상 변경
                              : Colors.transparent,
                              width: 2.0,
                            ),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(room.imagePath),
                              radius: 30,
                            ),
                            title: Text(
                              room.roomName,
                              style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: index < chatsHandler.lastChats.length
                            ? Text(
                              chatsHandler.lastChats[index].text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                            )
                            : const Text('채팅이 없습니다.',
                              style: TextStyle(
                                fontSize: 14, color: Colors.grey
                              )
                            ),
                            trailing: index < chatsHandler.lastChats.length? 
                            Padding(
                              padding: const EdgeInsets.only(top:20.0),
                              child: Text(
                                DateTime.now().difference(DateTime.parse(
                                  chatsHandler.lastChats[index].timestamp)) <
                                  const Duration(hours: 24) ?
                                  chatsHandler.lastChats[index].timestamp.substring(11, 16):
                                    "${chatsHandler.lastChats[index].timestamp.substring(5, 7)}월 ${chatsHandler.lastChats[index].timestamp.substring(8, 10)}일",
                                style: const TextStyle(
                                  fontSize: 13, color: Colors.grey
                                ),
                              ),
                            ): null,
                          ),
                        ),
                      ),
                    )
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: chatsHandler.chatShow.value? 
          chatDetail(context,):
           Center(child: Image.asset('images/ai.png'),
          ),
        ),
      ]
    );
  }
  Widget chatDetail(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: chatsHandler.opacity.value,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/ai.png',),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
       Column(
        children: [
          Material(
            elevation: 6.0, // elevation 추가
            color: Colors.teal[200], // 배경색 추가
            child: Container(
              width: double.infinity, // 가로로 꽉 채우기
              padding: const EdgeInsets.symmetric(vertical: 12), // 상하 간격 조절
              child: Text(
                chatsHandler.currentRoomName.value,
                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 텍스트 색상
                ),
              ),
            ),
          ),
          Expanded(
            child: chatList(context),
          ),
          chatInputField(context),
        ],
      )
      ],
    );
  }

  Widget chatList(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      chatsHandler.listViewContoller
          .jumpTo(chatsHandler.listViewContoller.position.maxScrollExtent);
    });
    return ListView.builder(
      controller: chatsHandler.listViewContoller,
      itemCount: chatsHandler.chats.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        ChatList chat = chatsHandler.chats[index];
        index >0 ? print(int.parse(chat.timestamp.substring(14, 16)) == int.parse(chatsHandler.chats[index-1].timestamp.substring(14,16))) : print('a');
        if (chatsHandler.checkToday(chat)) {
          String date = chat.text.substring(3, 13);
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width/8,
                height: MediaQuery.of(context).size.height/25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black45
                ),
                child: Text(
                  "${date.substring(0,4)}년 ${date.substring(5,7)}월 ${date.substring(8,10)}일",
                  style: TextStyle(fontSize: 16, color: Colors.grey[200]),
                ),
              ),
            ),
          );
        }

        bool isSender = chat.sender == userHandler.box.read('userEmail');
        return Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.end, 
            children: isSender? [
              Text(
                chat.timestamp.substring(11, 16),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 4), 
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chat.text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ]:[
              Padding(
                padding: const EdgeInsets.only(bottom:12.0),
                child: SizedBox(
                    child: index >0 ? chat.sender == chatsHandler.chats[index-1].sender ?
                int.parse(chat.timestamp.substring(14, 16)) == int.parse(chatsHandler.chats[index-1].timestamp.substring(14,16)) ?CircleAvatar(
                  backgroundImage: NetworkImage(
                    chatsHandler.getUserImageByEmail(chatsHandler.users, chat.sender)!
                  ),
                  radius: 35,
                ) :const SizedBox(width: 70,):CircleAvatar(
                  backgroundImage: NetworkImage(
                    chatsHandler.getUserImageByEmail(chatsHandler.users, chat.sender)!
                  ),
                  radius: 35,
                ):CircleAvatar(
                  backgroundImage: NetworkImage(
                    chatsHandler.getUserImageByEmail(chatsHandler.users, chat.sender)!
                  ),
                  radius: 35,
                )
                  ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: index >0 ? chat.sender == chatsHandler.chats[index-1].sender ?
                  int.parse(chat.timestamp.substring(14, 16)) == int.parse(chatsHandler.chats[index-1].timestamp.substring(14,16)) ?Text(
                        chatsHandler.getUserNameByEmail(chatsHandler.users, chat.sender)!,
                        style: const TextStyle(fontSize: 15),
                      ) :SizedBox():Text(
                        chatsHandler.getUserNameByEmail(chatsHandler.users, chat.sender)!,
                        style: const TextStyle(fontSize: 15),
                      ):Text(
                        chatsHandler.getUserNameByEmail(chatsHandler.users, chat.sender)!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:7.0),
                          child: Text(
                            chat.timestamp.substring(11, 16), 
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]
          ),
        );
      },
    );
  }

  Widget chatInputField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController,
              decoration: const InputDecoration(
                hintText: '메시지를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => inputChat(),
            icon: const Icon(Icons.send, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  inputChat() async {
    if (chatController.text.trim().isEmpty) return;
    ChatList newChat = ChatList(text: chatController.text.trim(), timestamp: DateTime.now().toString(), sender: userHandler.box.read('userEmail'),roomId: chatsHandler.currentRoomId.value);
    await chatsHandler.addChat(newChat);
    chatController.clear();
  }
}
