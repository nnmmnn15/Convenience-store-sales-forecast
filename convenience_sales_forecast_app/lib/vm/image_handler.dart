/*
author: 이원영
Description: Image Handler
Fixed: 11/21
Usage: Image_Picker를 사용해서 프로필 이미지 변경
*/
import 'dart:io';
import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageHandler extends GetxController {
  XFile? imageFile;
  File? imgFile;
  RxInt firstDisp = 0.obs;
  final ImagePicker picker = ImagePicker();
  String filename = "";

  // 갤러리에서 사진 가져오기
  getImageFromGallery(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    pickedFile == null ? imgFile = File(imageFile!.path): '';
    update();
  }

  // 갤러리에서 사진 가져오기(수정할 때)
  getImageFromGalleryEdit(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      imageFile = XFile(pickedFile.path);
      imgFile = File(imageFile!.path);
      firstDisp++;
      update();
    }
  }

  // FireStore에 가져온 사진 업로드 후 링크 가져오기
  preparingImage() async{
    String fileName = '${Get.find<UserHandler>().box.read('userEmail')}${DateTime.now().millisecondsSinceEpoch}.jpg';
    final firebaseStorage = FirebaseStorage.instance.ref().child(fileName);
    if(imgFile != null){
      await firebaseStorage.putFile(imgFile!);
      String downloadURL = await firebaseStorage.getDownloadURL();
      return downloadURL;
    }else{
      return;
    }
  }
}