// lib/features/auth/view/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart'; // ⭐ 경로 수정

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
        backgroundColor: Colors.blueGrey[700],
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('모든 필드를 올바르게 입력해주세요.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('비밀번호가 일치하지 않습니다.');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        },
      );

      // 회원가입 데이터 준비 (isDoctor는 기본 false로 가정)
      final userData = {
        'email': _emailController.text.trim(),
        'password': _passwordController.text.trim(),
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'birth': _birthController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isDoctor': false, // 기본적으로 환자로 회원가입
      };

      final error = await authViewModel.registerUser(userData); // ⭐ ViewModel 메서드 호출

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (error == null) {
        _showSnack('회원가입 성공!');
        context.go('/login'); // 회원가입 성공 후 로그인 화면으로 이동
      } else {
        _showSnack('회원가입 실패: $error');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showSnack('회원가입 중 예기치 않은 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원가입',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '새 계정 생성',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '이메일 (아이디)',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(12)),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return '유효한 이메일 형식을 입력해주세요.';
                      }
                      // 아이디 중복 확인 (비동기 유효성 검사)
                      return null; // 초기에는 null 반환, 나중에 비동기 검사 결과 반영
                    },
                    onEditingComplete: () async {
                      if (_emailController.text.isNotEmpty) {
                        final authViewModel = context.read<AuthViewModel>();
                        final exists = await authViewModel.checkUserIdDuplicate(_emailController.text.trim()); // ⭐ ViewModel 메서드 호출
                        if (exists) {
                          _showSnack('이미 사용 중인 이메일입니다.');
                          _formKey.currentState?.validate(); // 유효성 검사 다시 실행하여 오류 메시지 표시
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(12)),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '비밀번호 확인',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent, width: 2), borderRadius: BorderRadius.circular(12)),
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 다시 입력해주세요.';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildTextFormField(
                    controller: _nameController,
                    labelText: '이름',
                    icon: Icons.person_outline,
                    validator: (value) => value!.isEmpty ? '이름을 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildGenderSelection(),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _birthController,
                    labelText: '생년월일 (YYYY-MM-DD)',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value!.isEmpty) return '생년월일을 입력해주세요.';
                      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                        return '유효한 날짜 형식(YYYY-MM-DD)을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _phoneController,
                    labelText: '전화번호',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                      ),
                      child: Text(
                        '회원가입',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      '이미 계정이 있으신가요? 로그인',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Function(String)? onEditingComplete,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
      onEditingComplete: onEditingComplete != null ? () => onEditingComplete(controller.text) : null,
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            '성별',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              border: InputBorder.none, // DropdownButtonFormField 자체의 border 제거
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('남성')),
              DropdownMenuItem(value: 'F', child: Text('여성')),
              DropdownMenuItem(value: 'O', child: Text('기타')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) => value == null ? '성별을 선택해주세요.' : null,
          ),
        ),
      ],
    );
  }
}
