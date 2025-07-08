// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:intl/date_symbol_data_local.dart';

// 앱 기본 관련 임포트
import 'package:t0703/app/router.dart';
import 'package:t0703/app/theme.dart'; // ✅ AppTheme 임포트 경로 확인

// 의사 포털 관련 ViewModel 임포트
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:t0703/features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/calendar_viewmodel.dart';
import 'package:t0703/features/patient/viewmodel/patient_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/doctor_dashboard_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/consultation_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/appointment_viewmodel.dart'; // ✅ AppointmentViewModel 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  final String globalBaseUrl;

  if (kIsWeb) {
    globalBaseUrl = "http://127.0.0.1:5000/api";
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    globalBaseUrl = "http://10.0.2.2:5000/api";
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    globalBaseUrl = "http://localhost:5000/api";
  } else {
    globalBaseUrl = "http://192.168.0.2:5000/api";
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => UserInfoViewModel()),
        ChangeNotifierProvider(create: (context) => CalendarViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => PatientViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => DoctorDashboardViewModel()),
        ChangeNotifierProvider(create: (context) => ConsultationViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => AppointmentViewModel(baseUrl: globalBaseUrl)), // ✅ AppointmentViewModel 추가
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
      title: 'MediTooth Doctor Portal',
      theme: AppTheme.lightTheme, // ✅ AppTheme 사용
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
