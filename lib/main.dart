// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb을 위해 필요
import 'package:go_router/go_router.dart'; // go_router 임포트 추가

import 'package:t0703/app/router.dart'; // ⭐ 경로 수정
import 'package:t0703/app/theme.dart'; // ⭐ 경로 수정
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart'; // ⭐ 경로 수정
import 'package:t0703/features/mypage/viewmodel/userinfo_viewmodel.dart'; // ⭐ 경로 수정
// import 'package:t0703/features/chatbot/viewmodel/chatbot_viewmodel.dart'; // ⚠️ ChatbotViewModel 제거 (의사 웹 앱에 불필요)
// ⭐ 의사 포털 관련 ViewModel 임포트
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_request_list_viewmodel.dart'; // ⭐ 경로 수정
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_detail_viewmodel.dart'; // ⭐ 경로 수정
import 'package:t0703/features/doctor_portal/viewmodel/calendar_viewmodel.dart'; // ⭐ 경로 수정

// Views (GoRouter 설정에 필요하므로 임포트 유지)
import 'package:t0703/features/auth/view/login_screen.dart';
import 'package:t0703/features/auth/view/register_screen.dart';
import 'package:t0703/features/auth/view/find-Account_screen.dart';
import 'package:t0703/features/home/view/home_screen.dart'; // 환자 홈 화면 (라우터에 정의되어 있다면 유지)
import 'package:t0703/features/doctor_portal/view/doctor_dashboard_screen.dart';


void main() {
  final String globalBaseUrl = kIsWeb
      ? "http://127.0.0.1:5000"
      : "http://10.0.2.2:5000";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => UserInfoViewModel()),
        // ChangeNotifierProvider(create: (context) => ChatbotViewModel(baseUrl: globalBaseUrl)), // ⚠️ ChatbotViewModel 제거
        // ⭐ 의사 포털 관련 ViewModel 생성자에 globalBaseUrl 전달
        ChangeNotifierProvider(create: (context) => TelemedicineRequestListViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => TelemedicineDetailViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => CalendarViewModel(baseUrl: globalBaseUrl)),
      ],
      child: const MediToothApp(),
    ),
  );
}

class MediToothApp extends StatelessWidget {
  const MediToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      theme: AppTheme.lightTheme, // app/theme.dart에서 정의된 테마 사용
      routerConfig: AppRouter.router, // app/router.dart에서 정의된 라우터 사용
      debugShowCheckedModeBanner: false,
    );
  }
}
