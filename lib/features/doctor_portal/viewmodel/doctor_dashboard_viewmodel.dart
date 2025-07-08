// lib/features/doctor_portal/viewmodel/doctor_dashboard_viewmodel.dart

import 'package:flutter/material.dart';

enum DoctorMenu {
  telemedicineRequests, // 환자 진료 (이전 비대면 진료 신청)
  calendar,             // 캘린더
  patientList,          // 환자 목록
  // alarm,             // ✅ 제거됨
  // recommendation,    // ✅ 제거됨
}

class DoctorDashboardViewModel with ChangeNotifier {
  DoctorMenu _selectedMenu = DoctorMenu.telemedicineRequests;

  DoctorMenu get selectedMenu => _selectedMenu;

  void setSelectedMenu(DoctorMenu menu) {
    if (_selectedMenu != menu) {
      _selectedMenu = menu;
      notifyListeners();
    }
  }
}
