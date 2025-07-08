// lib/features/doctor_portal/view/doctor_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:t0703/features/doctor_portal/viewmodel/doctor_dashboard_viewmodel.dart';
import 'package:t0703/features/patient/view/patient_list_screen.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_request_list_screen.dart';
import 'package:t0703/features/doctor_portal/view/calendar_screen.dart';
// import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart'; // 더 이상 직접 사용되지 않음

// 임시 알람 화면 (더 이상 사용되지 않음)
// class AlarmScreen extends StatelessWidget { ... }

// 임시 추천 화면 (더 이상 사용되지 않음)
// class RecommendationScreen extends StatelessWidget { ... }


class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DoctorDashboardViewModel>();

    Widget mainContent;
    switch (dashboardViewModel.selectedMenu) {
      case DoctorMenu.telemedicineRequests:
        mainContent = const TelemedicineRequestListScreen();
        break;
      case DoctorMenu.calendar:
        mainContent = const CalendarScreen();
        break;
      case DoctorMenu.patientList:
        mainContent = const PatientListScreen();
        break;
      // case DoctorMenu.alarm: // ✅ 제거됨
      //   mainContent = const AlarmScreen();
      //   break;
      // case DoctorMenu.recommendation: // ✅ 제거됨
      //   mainContent = const RecommendationScreen();
      //   break;
    }

    return Scaffold(
      body: Row(
        children: [
          // 좌측 내비게이션 바
          Container(
            width: 250,
            color: Colors.blueGrey[800],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  alignment: Alignment.center,
                  child: const Text(
                    'TOOTH AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.list_alt,
                  title: '환자 진료',
                  isSelected: dashboardViewModel.selectedMenu == DoctorMenu.telemedicineRequests,
                  onTap: () {
                    dashboardViewModel.setSelectedMenu(DoctorMenu.telemedicineRequests);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: '진료 캘린더',
                  isSelected: dashboardViewModel.selectedMenu == DoctorMenu.calendar,
                  onTap: () {
                    dashboardViewModel.setSelectedMenu(DoctorMenu.calendar);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_alt,
                  title: '환자 목록',
                  isSelected: dashboardViewModel.selectedMenu == DoctorMenu.patientList,
                  onTap: () {
                    dashboardViewModel.setSelectedMenu(DoctorMenu.patientList);
                  },
                ),
                // ✅ 알람 메뉴 제거됨
                // ✅ 추천 메뉴 제거됨
                const Spacer(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: '로그아웃',
                  isSelected: false,
                  onTap: () {
                    context.read<AuthViewModel>().logout();
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // 메인 콘텐츠 영역
          Expanded(
            child: mainContent,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blueAccent.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.blueGrey[200]),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey[200],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
