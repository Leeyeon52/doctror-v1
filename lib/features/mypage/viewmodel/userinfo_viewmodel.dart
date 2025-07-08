// lib/features/mypage/viewmodel/userinfo_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/auth/model/user.dart'; // ✅ User 모델 임포트

class UserInfoViewModel extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void loadUser(User user) { // ✅ User 모델을 인자로 받도록 수정
    _user = user;
    notifyListeners();
  }

  // TODO: 사용자 정보 업데이트, 로그아웃 등 다른 로직 추가
}
