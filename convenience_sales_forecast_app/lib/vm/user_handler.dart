/*
author: 이원영
Description: 채팅 ui
Fixed: 11/20
Usage: 점주들 그룹 채팅
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/users.dart';
import 'package:convenience_sales_forecast_app/view/login.dart';
import 'package:convenience_sales_forecast_app/view/rail_bar.dart';
import 'package:convenience_sales_forecast_app/vm/chat_handler.dart';
import 'package:convenience_sales_forecast_app/vm/image_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserHandler extends ImageHandler {
  final users = <Users>[].obs;
  final currentUser = Rxn<Users>(); 
  final box = GetStorage();
  String userEmail = '';
  String userName = '';
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('user');
 
  @override
  void onInit() async {
    super.onInit();
    getUserData();
  }

  gotoEdit() async{
    firstDisp.value = 0;
    imgFile = null;
    update();
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth = await gUser.authentication;
    userEmail = gUser.email;
    userName = gUser.displayName!;
    box.write('userEmail', userEmail);
    box.write('userName', userName);
    final DocumentReference userDoc = FirebaseFirestore.instance.collection('user').doc(userEmail);
    final DocumentSnapshot docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': userEmail, // userEmail 변수를 email 필드에 저장
        'image': 'https://via.placeholder.com/150', // 기본 이미지 URL
        'name': '예비 점주', // 기본 이름
      });
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    Get.to(() => RailBar());
    await getMyInfo(box.read('userEmail'));
    return userCredential;
  }

  getUserData() async{
    _users.snapshots().listen((event) {
      users.value = event.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Users(email: data['email'], image: data['image'], name: data['name']);
      }).toList();
    });
    update();
  }

  getMyInfo(String email) async{
    _users.doc(email).snapshots().listen((DocumentSnapshot docSnapshot) {
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      currentUser.value = Users.fromMap(data, email);
    } else {
      currentUser.value = null; // 문서가 삭제되었을 경우 처리
    }
  });
  }

  updateProfileImage(name) async{
    String imageURL = await preparingImage() ?? currentUser.value!.image;
    await FirebaseFirestore.instance.collection('user').doc(box.read('userEmail')).update({
      'name' : name,
      'image': imageURL,
    });
    update();
  }

  deleteProfileImage() async{
    await FirebaseFirestore.instance.collection('user').doc(box.read('userEmail')).update({
      'image': 'https://via.placeholder.com/150',
    });
    update();
  }


  clearUser() async{
    users.clear();
    currentUser.value!.email ='' ;
    currentUser.value!.name ='' ;
    currentUser.value!.image ='' ;
    box.write('userEmail', '');
    update();
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    await box.write('userEmail', "");
    await Get.find<ChatHandler>().clearChat();
    await clearUser();
    Get.offAll(()=> Login());
    update();
  }

}
