// lib/features/doctor_portal/viewmodel/appointment_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:t0703/features/doctor_portal/model/appointment.dart';

class AppointmentViewModel with ChangeNotifier {
  final String _baseUrl;
  List<Appointment> _appointments = [];
  String? _errorMessage;
  bool _isLoading = false;

  AppointmentViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  List<Appointment> get appointments => _appointments;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 특정 의사의 특정 날짜 예약 목록 불러오기
  Future<void> fetchAppointmentsByDate(int doctorId, String date) async {
    _setLoading(true);
    _setErrorMessage(null);
    _appointments = []; // 기존 목록 초기화
    try {
      final res = await http.get(Uri.parse('$_baseUrl/appointment/list_by_date/$doctorId/$date'));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _appointments = data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        String message = '예약 목록 불러오기 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _setErrorMessage(message);
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류: ${e.toString()}');
      if (kDebugMode) {
        print('예약 목록 불러오기 중 네트워크 오류: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // 새로운 예약 추가
  Future<bool> addAppointment({
    required int patientId,
    required int doctorId,
    required String appointmentDate,
    required String appointmentTime,
    String status = '대기중',
    String? notes,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/appointment/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientId': patientId,
          'doctorId': doctorId,
          'appointmentDate': appointmentDate,
          'appointmentTime': appointmentTime,
          'status': status,
          'notes': notes,
        }),
      );

      if (res.statusCode == 201) {
        // 성공적으로 추가되면 해당 날짜의 목록을 새로고침
        await fetchAppointmentsByDate(doctorId, appointmentDate);
        return true;
      } else {
        String message = '예약 추가 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _setErrorMessage(message);
        return false;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류: ${e.toString()}');
      if (kDebugMode) {
        print('예약 추가 중 네트워크 오류: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 예약 정보 업데이트
  Future<bool> updateAppointment({
    required int appointmentId,
    required int doctorId, // 목록 새로고침을 위해 필요
    required String originalDate, // 목록 새로고침을 위해 필요
    String? appointmentDate,
    String? appointmentTime,
    String? status,
    String? notes,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/appointment/update/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appointmentDate': appointmentDate,
          'appointmentTime': appointmentTime,
          'status': status,
          'notes': notes,
        }),
      );

      if (res.statusCode == 200) {
        // 업데이트 성공 후 해당 날짜의 목록을 새로고침 (날짜가 변경될 수 있으므로 두 날짜 모두 새로고침)
        if (appointmentDate != null && appointmentDate != originalDate) {
          await fetchAppointmentsByDate(doctorId, originalDate); // 이전 날짜
        }
        await fetchAppointmentsByDate(doctorId, appointmentDate ?? originalDate); // 새 날짜 또는 이전 날짜
        return true;
      } else {
        String message = '예약 업데이트 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _setErrorMessage(message);
        return false;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류: ${e.toString()}');
      if (kDebugMode) {
        print('예약 업데이트 중 네트워크 오류: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 예약 삭제
  Future<bool> deleteAppointment(int appointmentId, int doctorId, String date) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/appointment/delete/$appointmentId'));

      if (res.statusCode == 200) {
        // 성공적으로 삭제되면 해당 날짜의 목록을 새로고침
        await fetchAppointmentsByDate(doctorId, date);
        return true;
      } else {
        String message = '예약 삭제 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _setErrorMessage(message);
        return false;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류: ${e.toString()}');
      if (kDebugMode) {
        print('예약 삭제 중 네트워크 오류: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
