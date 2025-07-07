// lib/features/auth/viewmodel/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/auth/model/user.dart'; // ⭐ 경로 수정

class AuthViewModel extends ChangeNotifier {
  final String baseUrl; // ⭐ baseUrl 추가
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  AuthViewModel({required this.baseUrl}); // ⭐ 생성자 추가

  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<User?> loginUser(String email, String password) async { // userId 대신 email로 변경
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ⭐ 실제 백엔드 로그인 API 호출 로직 (baseUrl 사용)
      // 예: final response = await http.post(Uri.parse('$baseUrl/login'), body: {'email': email, 'password': password});

      await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

      if (email == 'doctor@example.com' && password == 'doctorpass') {
        _currentUser = User(
          uid: 'doc_123',
          email: email,
          name: '김닥터',
          isDoctor: true,
          gender: '남', // 가상 데이터 추가
          birth: '1980-01-01',
          phone: '010-1234-5678',
        );
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      } else if (email == 'patient@example.com' && password == 'patientpass') {
        _currentUser = User(
          uid: 'pat_456',
          email: email,
          name: '이환자',
          isDoctor: false,
          gender: '여', // 가상 데이터 추가
          birth: '1995-05-15',
          phone: '010-9876-5432',
        );
        _isLoading = false;
        notifyListeners();
        return _currentUser;
      } else {
        _errorMessage = '아이디 또는 비밀번호를 확인해주세요.';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = '로그인 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
    // TODO: 실제 로그아웃 API 호출 및 세션 정리
  }

  // ⭐ register_screen.dart 에서 사용될 더미 메서드 추가
  Future<bool> checkUserIdDuplicate(String email) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 시뮬레이션
    return email == 'existing@example.com'; // 이미 존재하는 아이디라고 가정
  }

  Future<String?> registerUser(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
    // 실제로는 userData를 백엔드로 전송하여 회원가입 처리
    if (userData['email'] == 'fail@example.com') {
      return '회원가입 실패: 서버 오류';
    }
    return null; // 성공 시 null 반환
  }

  // ⭐ mypage_screen.dart 에서 사용될 더미 메서드 추가
  Future<String?> deleteUser(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
    // 실제로는 백엔드에서 사용자 삭제 처리
    if (email == 'error@example.com') {
      return '사용자 삭제 실패: 서버 오류';
    }
    _currentUser = null; // 삭제 성공 시 현재 사용자 정보 초기화
    notifyListeners();
    return null; // 성공 시 null 반환
  }
}
