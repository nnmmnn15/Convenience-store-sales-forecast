import 'package:convenience_sales_forecast_app/vm/user_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:convenience_sales_forecast_app/view/rail_bar.dart';
import 'package:convenience_sales_forecast_app/view/sign_up.dart';

class Login extends StatelessWidget {
  final UserHandler userHandler = Get.put(UserHandler());
  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('images/ai.png', height: 100),
                const SizedBox(height: 48),
                // _buildTextField('아이디'),
                // const SizedBox(height: 16),
                // _buildTextField('비밀번호', isPassword: true),
                // const SizedBox(height: 24),
                // _buildButton('로그인', onPressed: () {
                //   // 일반 로그인 로직
                // }),
                // const SizedBox(height: 16),
                SizedBox(
                  width: 250,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey), // 버튼 테두리 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        UserCredential? userCredential =
                            await userHandler.signInWithGoogle();
                        if (userCredential != null) {
                          Get.to(() => RailBar());
                        } else {
                          Get.snackbar(
                            '오류',
                            'Google 로그인 실패',
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          '오류',
                          'Google 로그인 중 오류 발생',
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'images/google.png',
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 16), // 이미지와 텍스트 사이 간격
                        const Text(
                          '구글 아이디로 로그인',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // _buildButton('Google로 로그인', onPressed: () async {
                //   try {
                //     UserCredential? userCredential =
                //         await userHandler.signInWithGoogle();
                //     if (userCredential != null) {
                //       Get.to(() => RailBar());
                //     } else {
                //       Get.snackbar(
                //         '오류',
                //         'Google 로그인 실패',
                //       );
                //     }
                //   } catch (e) {
                //     Get.snackbar(
                //       '오류',
                //       'Google 로그인 중 오류 발생',
                //     );
                //   }
                // }),

                // const SizedBox(height: 16),
                // TextButton(
                //   child: const Text('회원가입'),
                //   onPressed: () {
                //     Get.to(() => const SignUp());
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildButton(String label, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(label),
      ),
    );
  }
}
