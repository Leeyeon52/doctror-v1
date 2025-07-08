// lib/features/auth/view/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // ✅ 이름 컨트롤러 추가
  final _phoneController = TextEditingController(); // ✅ 핸드폰 번호 컨트롤러 추가
  final _clinicNameController = TextEditingController(); // ✅ 치과 이름 컨트롤러 추가
  final _clinicAddressController = TextEditingController(); // ✅ 치과 주소 컨트롤러 추가
  bool _isDoctor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose(); // ✅ 컨트롤러 dispose
    _phoneController.dispose(); // ✅ 컨트롤러 dispose
    _clinicNameController.dispose(); // ✅ 컨트롤러 dispose
    _clinicAddressController.dispose(); // ✅ 컨트롤러 dispose
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

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim(); // ✅ 이름 값 가져오기
    final phoneNumber = _phoneController.text.trim(); // ✅ 핸드폰 번호 값 가져오기
    final clinicName = _clinicNameController.text.trim(); // ✅ 치과 이름 값 가져오기
    final clinicAddress = _clinicAddressController.text.trim(); // ✅ 치과 주소 값 가져오기

    final authViewModel = context.read<AuthViewModel>();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        },
      );

      // ✅ registerUser 메서드에 추가 필드 전달
      final success = await authViewModel.registerUser(
        email,
        password,
        name: name,
        phoneNumber: phoneNumber,
        clinicName: clinicName,
        clinicAddress: clinicAddress,
        isDoctor: _isDoctor,
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      }

      if (success) {
        _showSnack('회원가입 성공! 로그인 해주세요.');
        context.go('/login'); // 회원가입 성공 후 로그인 화면으로 이동
      } else {
        _showSnack(authViewModel.errorMessage ?? '회원가입 실패: 알 수 없는 오류');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop(); // 이전 화면 (로그인 화면)으로 돌아가기
          },
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
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '새 계정 생성',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '서비스 이용을 위해 회원 정보를 입력해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '이메일',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: 'example@example.com',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return '유효한 이메일 형식을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController, // ✅ 이름 필드 추가
                    keyboardType: TextInputType.text,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '이름',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: '이름을 입력해주세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: '비밀번호를 입력해주세요 (최소 6자)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 최소 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController, // ✅ 핸드폰 번호 필드 추가
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      labelText: '핸드폰 번호',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      hintText: '010-1234-5678',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '핸드폰 번호를 입력해주세요.';
                      }
                      // 간단한 숫자 및 하이픈 유효성 검사
                      if (!RegExp(r'^\d{2,3}-\d{3,4}-\d{4}$').hasMatch(value)) {
                        return '유효한 핸드폰 번호 형식을 입력해주세요 (예: 010-1234-5678).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // 의사 계정일 경우에만 치과 정보 필드 표시
                  if (_isDoctor) ...[
                    TextFormField(
                      controller: _clinicNameController, // ✅ 치과 이름 필드 추가
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: '치과 이름',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: 'OO치과',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.local_hospital_outlined, color: Colors.grey[600]),
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
                      validator: (value) {
                        if (_isDoctor && (value == null || value.isEmpty)) {
                          return '치과 이름을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _clinicAddressController, // ✅ 치과 주소 필드 추가
                      keyboardType: TextInputType.streetAddress,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        labelText: '치과 주소',
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        hintText: '서울특별시 강남구 테헤란로 123',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey[600]),
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
                      validator: (value) {
                        if (_isDoctor && (value == null || value.isEmpty)) {
                          return '치과 주소를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isDoctor,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isDoctor = newValue ?? false;
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      const Text(
                        '의사입니다 (의료인 계정으로 등록)',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
}
