import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super. key}) ;

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('images/ai.png', height: 40),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_idController, '아이디'),
                  const SizedBox(height: 16),
                  _buildTextField(_nicknameController, '닉네임'),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, '비밀번호', isPassword: true),
                  const SizedBox(height: 16),
                  _buildTextField(_confirmPasswordController, '비밀번호 확인', isPassword: true),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, '이메일 주소', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                    // 예: Firebase Auth를 사용한 회원가입
                    // FirebaseAuth.instance.createUserWithEmailAndPassword(
                    //   email: _emailController.text,
                    //   password: _passwordController.text,
                    // ).then((userCredential) {
                    //   // 회원가입 성공 처리
                    // }).catchError((error) {
                    //   // 오류 처리
                    // });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('회원가입 완료'),
              ),
              )],
          ),
        ),
      ),
    )));
  }


Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label를 입력해주세요';
        }
        if (label == '이메일 주소' && !value.contains('@')) {
          return '유효한 이메일 주소를 입력해주세요';
        }
        if (label == '비밀번호 확인' && value != _passwordController.text) {
          return '비밀번호가 일치하지 않습니다';
        }
        return null;
      },
    );
  }
}