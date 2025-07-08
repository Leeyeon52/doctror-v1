// lib/app/router.dart

import 'package:go_router/go_router.dart';
import 'package:t0703/features/auth/view/login_screen.dart';
import 'package:t0703/features/auth/view/register_screen.dart';
import 'package:t0703/features/doctor_portal/view/doctor_dashboard_screen.dart';
import 'package:t0703/features/patient/view/patient_list_screen.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart';
import 'package:t0703/features/patient/view/patient_detail_screen.dart'; // ✅ PatientDetailScreen 임포트

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/doctor_dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/patients',
        builder: (context, state) => const PatientListScreen(),
      ),
      GoRoute(
        path: '/telemedicine_detail/:consultationId',
        builder: (context, state) {
          final consultationId = int.parse(state.pathParameters['consultationId']!);
          return TelemedicineDetailScreen(consultationId: consultationId);
        },
      ),
      GoRoute(
        path: '/patient_detail/:patientId', // ✅ PatientDetailScreen 라우트 추가
        builder: (context, state) {
          final patientId = int.parse(state.pathParameters['patientId']!);
          return PatientDetailScreen(patientId: patientId);
        },
      ),
    ],
  );
}
