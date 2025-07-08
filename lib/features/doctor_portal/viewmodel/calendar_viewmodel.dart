// lib/features/doctor_portal/viewmodel/calendar_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // isSameDay 함수 사용을 위해 임포트

// Appointment 모델 (예시, 실제 모델은 별도 파일에 정의되어야 함)
class Appointment {
  final String patientName;
  final String time;
  final String description;
  final DateTime date; // 약속 날짜 추가

  Appointment({required this.patientName, required this.time, required this.description, required this.date});
}

class CalendarViewModel extends ChangeNotifier {
  final String baseUrl; // ✅ baseUrl 추가

  CalendarViewModel({required this.baseUrl}) { // ✅ 생성자 수정
    _selectedDay = _focusedDay; // 초기 선택 날짜 설정
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 예시 데이터 (실제로는 API에서 가져와야 함)
  final Map<DateTime, List<Appointment>> _events = {
    DateTime.utc(2025, 7, 10): [
      Appointment(patientName: '김철수', time: '10:00', description: '정기 검진', date: DateTime.utc(2025, 7, 10)),
      Appointment(patientName: '이영희', time: '14:30', description: '충치 치료', date: DateTime.utc(2025, 7, 10)),
    ],
    DateTime.utc(2025, 7, 15): [
      Appointment(patientName: '박민수', time: '11:00', description: '스케일링', date: DateTime.utc(2025, 7, 15)),
    ],
  };

  // Getters
  CalendarFormat get calendarFormat => _calendarFormat;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;

  List<Appointment> get selectedEvents {
    if (_selectedDay == null) return [];
    return _events[DateTime.utc(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [];
  }

  // Methods
  List<Appointment> getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay; // 선택된 날짜로 포커스 이동
      notifyListeners();
    }
  }

  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  void deleteAppointment(Appointment appointment) {
    final day = DateTime.utc(appointment.date.year, appointment.date.month, appointment.date.day);
    if (_events.containsKey(day)) {
      _events[day]!.remove(appointment);
      if (_events[day]!.isEmpty) {
        _events.remove(day);
      }
      notifyListeners();
    }
  }

  void addAppointment(Appointment appointment) {
    final day = DateTime.utc(appointment.date.year, appointment.date.month, appointment.date.day);
    _events.putIfAbsent(day, () => []).add(appointment);
    notifyListeners();
  }
}
