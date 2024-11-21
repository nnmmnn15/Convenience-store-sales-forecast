/*
author: 이원영
Description: 마이페이지
Fixed: 11/21
Usage: 간단한 내 정보 페이지 (Google Login으로 구현되어 정보가 몇개 없음)
*/
import 'package:convenience_sales_forecast_app/model/users.dart';
import 'package:convenience_sales_forecast_app/view/mypage_edit.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Mypage extends StatelessWidget {
  Mypage({super.key});
  final UserHandler userHandler = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이 페이지',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            onPressed: () async{
              await userHandler.gotoEdit();
              Get.to(()=> MypageEdit());
            }, 
            icon: const Icon(Icons.edit)
          )
        ],
      ),
      body: GetBuilder<UserHandler>(builder: (_) {
        return FutureBuilder(
          future:userHandler.getMyInfo(userHandler.box.read('userEmail')),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else {
              return Obx(() {
                if(userHandler.currentUser.value!.email.isEmpty){
                  Get.delete<UserHandler>();
                }
                final result = userHandler.currentUser;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileSection(context, result.value!),
                      _buildInfoSection(result.value!),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16
                      ),
                      _buildActionButtons(context, result.value!),
                    ],
                  ),
                );
              });
            }
          },
        );}
      )
    );
  }

  _buildProfileSection(BuildContext context, Users currentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.green.shade50,
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(currentUser.image),
            ),
            const SizedBox(height: 16),
            Text(
              currentUser.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildInfoSection(Users currentUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '회원 정보',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('이름', currentUser.name),
                  const SizedBox(height: 8),
                  _buildInfoItem('이메일', currentUser.email),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildInfoItem(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  _buildActionButtons(BuildContext context, Users currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.logout,
            label: '로그아웃',
            onPressed: () => showDialog(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  showDialog() {
    Get.defaultDialog(
      title: "로그아웃",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      middleText: '로그아웃 하시겠습니까?',
      textConfirm: "확인",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.lightGreen,
      onConfirm: () async {
        await userHandler.signOut();
      },
    );
  }

}
