import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convenience_sales_forecast_app/model/users.dart';
import 'package:convenience_sales_forecast_app/view/rail_bar.dart';
import 'package:convenience_sales_forecast_app/vm/image_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserHandler extends ImageHandler {
  final users = <Users>[].obs;
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
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    Get.to(() => RailBar());
    return userCredential;
  }

  getUserData() async{
    _users.snapshots().listen((event) {
      users.value = event.docs.map((doc) {
        // 문서 데이터 가져오기
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Users(email: data['email'], image: data['image'], name: data['name']);
      }).toList();
    });
    update();
  }

}
