/*
author: 이원영
Description: 내 정보 수정
Fixed: 11/21
Usage: FireStore를 통해 프로필 사진 및 이름 수정하는 페이지
*/
import 'dart:io';
import 'package:convenience_sales_forecast_app/model/users.dart';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MypageEdit extends StatelessWidget {
  MypageEdit({super.key});

  final UserHandler userHandler = Get.find();
  final TextEditingController nameController = TextEditingController(
      text: Get.find<UserHandler>().currentUser.value!.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '내 정보 수정',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueGrey,
        ),
        body: GetBuilder<UserHandler>(builder: (_) {
          return FutureBuilder(
            future: userHandler.getMyInfo(userHandler.box.read('userEmail')),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              } else {
                return Obx(() {
                  final result = userHandler.currentUser;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileSection(context, result.value!),
                        _buildInfoSection(result.value!, context),
                        const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16),
                        _buildActionButtons(context, result.value!),
                      ],
                    ),
                  );
                });
              }
            },
          );
        }));
  }

  _buildProfileSection(BuildContext context, Users currentUser) {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.green.shade50,
      child: Center(
        child: Column(
          children: [
            const Text(
              '프로필 이미지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            GestureDetector(
              onTap: () => changeImage(context),
              child: userHandler.firstDisp.value == 0
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(currentUser.image))
                  : userHandler.imgFile == null
                      ? const Text('Image not found')
                      : CircleAvatar(
                          radius: MediaQuery.of(context).size.width /
                              20, // 너비에 따라 반지름 조정
                          backgroundImage: FileImage(
                              File(userHandler.imgFile!.path)), // 이미지 파일 설정
                          backgroundColor:
                              Colors.grey[200], // 이미지가 없을 때의 배경색 (옵션)
                        ),
            ),
          ],
        ),
      ),
    );
  }

  _buildInfoSection(Users currentUser, context) {
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
                  _buildInfoItem('이름', currentUser.name, context),
                  const SizedBox(height: 8),
                  _buildInfoItem('이메일', currentUser.email, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildInfoItem(String label, String value, context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // 텍스트와 필드 세로 정렬
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        label == '이름'
            ? SizedBox(
                width: MediaQuery.of(context).size.width / 7,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              )
            : Text(
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
            icon: Icons.edit_document,
            label: '수정',
            onPressed: () => showDialog(),
            color: Colors.blueGrey,
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
      title: "수정",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      middleText: '수정 하시겠습니까?',
      textConfirm: "확인",
      textCancel: "취소",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.black,
      buttonColor: Colors.blueGrey[300],
      onConfirm: () async {
        await userHandler.preparingImage();
        await userHandler.updateProfileImage(nameController.text.trim());
        Get.back();
        Get.back();
      },
    );
  }

  changeImage(context) {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Get.back();
              await userHandler.getImageFromGalleryEdit(ImageSource.gallery);
            },
            child: const Text(
              '프로필 사진 변경',
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              await userHandler.deleteProfileImage();
              Get.back();
            },
            child: const Text(
              '프로필 사진 삭제',
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Get.back(),
            child: const Text(
              '취소',
            )),
      ),
    );
  }
}
