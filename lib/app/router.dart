// C:\Users\user\Desktop\0703flutter_v2\lib\app\router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:t0703/features/auth/view/login_screen.dart'; // ⭐ 경로 수정
import 'package:t0703/features/auth/view/register_screen.dart'; // ⭐ 경로 수정
import 'package:t0703/features/auth/view/find-Account_screen.dart'; // ⭐ 경로 수정

// ⭐ 의사 포털 화면 임포트
import 'package:t0703/features/doctor_portal/view/doctor_dashboard_screen.dart';

// ⚠️ 아래 임포트들은 환자 관련 화면이므로 의사 웹 앱에서는 사용되지 않습니다.
// import '../features/home/view/main_scaffold.dart';
// import '../features/home/view/home_screen.dart';
// import '../features/chatbot/view/chatbot_screen.dart';
// import '../features/mypage/view/mypage_screen.dart';
// import '../features/diagnosis/view/upload_screen.dart';
// import '../features/diagnosis/view/result_screen.dart';
// import '../features/history/view/history_screen.dart';
// import '../features/diagnosis/view/realtime_prediction_screen.dart';
// import '../features/mypage/view/edit_profile_screen.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  // ShellRoute를 사용하지 않으므로 _shellNavigatorKey는 필요 없습니다.
  // static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey, // 최상위 NavigatorKey
    initialLocation: '/login', // 앱 시작 시 초기 경로

    routes: [
      // 로그인, 회원가입, 아이디/비밀번호 찾기 화면 (하단 탭 바 없음)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/find-account',
        builder: (context, state) => const FindAccountScreen(),
      ),

      // ⭐ 의사 대시보드 화면 (로그인 성공 시 이동할 메인 화면)
      // 이 화면 내부에 '비대면 진료 신청'과 '진료 캘린더' 탭이 포함됩니다.
      GoRoute(
        path: '/doctor_dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),

      // ⚠️ 아래는 환자 관련 라우트이므로 의사 웹 앱에서는 제거됩니다.
      // ShellRoute(
      //   navigatorKey: _shellNavigatorKey,
      //   builder: (context, state, child) {
      //     return MainScaffold(child: child, currentLocation: state.uri.toString());
      //   },
      //   routes: [
      //     GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      //     GoRoute(path: '/chatbot', builder: (context, state) => const ChatbotScreen()),
      //     GoRoute(
      //       path: '/mypage',
      //       builder: (context, state) => const MyPageScreen(),
      //       routes: [
      //         GoRoute(path: 'edit', builder: (context, state) => const EditProfileScreen()),
      //       ],
      //     ),
      //     GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
      //     GoRoute(path: '/upload', builder: (context, state) => const UploadScreen()),
      //     GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
      //   ],
      // ),
      // GoRoute(
      //   path: '/diagnosis/realtime',
      //   builder: (context, state) => const RealtimePredictionScreen(),
      // ),
    ],
  );
}
