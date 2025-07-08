// lib/features/doctor_portal/viewmodel/consultation_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:t0703/features/doctor_portal/model/consultation_record.dart';

class ConsultationViewModel with ChangeNotifier {
  final String _baseUrl;
  ConsultationRecord? _currentConsultation;
  List<ConsultationRecord> _patientConsultations = []; // ✅ 환자별 진료 기록 목록
  String? _errorMessage;
  bool _isLoading = false;

  ConsultationViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  ConsultationRecord? get currentConsultation => _currentConsultation;
  List<ConsultationRecord> get patientConsultations => _patientConsultations; // ✅ getter 추가
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

  // 특정 진료 기록 불러오기
  Future<void> fetchConsultationRecord(int recordId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final res = await http.get(Uri.parse('$_baseUrl/consultation/$recordId'));

      if (res.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(res.body);
        _currentConsultation = ConsultationRecord.fromJson(data);
      } else {
        String message = '진료 기록 불러오기 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          } else if (decodedBody is String && decodedBody.isNotEmpty) {
            message = decodedBody;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _setErrorMessage(message);
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류: ${e.toString()}');
      if (kDebugMode) {
        print('진료 기록 불러오기 중 네트워크 오류: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // ✅ 특정 환자의 모든 진료 기록 불러오기 메서드 추가
  Future<void> fetchConsultationRecordsByPatient(int patientId, int doctorId) async {
    _setLoading(true);
    _setErrorMessage(null);
    _patientConsultations = []; // 기존 목록 초기화
    try {
      // 백엔드 API 경로: /api/consultation/list/patient/<patient_id>
      final res = await http.get(Uri.parse('$_baseUrl/consultation/list/patient/$patientId?doctorId=$doctorId'));
      // 실제 백엔드에서 doctorId로 필터링하는 로직이 있다면 쿼리 파라미터로 넘겨줄 수 있습니다.
      // 현재 백엔드는 patient_id만으로 필터링하므로 doctorId는 클라이언트 측에서만 사용하거나,
      // 백엔드 API를 수정하여 doctorId로도 필터링하도록 해야 합니다.

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        _patientConsultations = data.map((json) => ConsultationRecord.fromJson(json)).toList();
      } else {
        String message = '환자 진료 기록 목록 불러오기 실패 (Status: ${res.statusCode})';
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
        print('환자 진료 기록 목록 불러오기 중 네트워크 오류: $e');
      }
    } finally {
      _setLoading(false);
    }
  }


  // 진료 기록 업데이트 (의사 수정 내용 등)
  Future<bool> updateConsultationRecord({
    required int recordId,
    String? chiefComplaint,
    String? diagnosis,
    String? treatmentPlan,
    String? maskingResult,
    String? aiResult,
    String? doctorModifications,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/consultation/update/$recordId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chiefComplaint': chiefComplaint,
          'diagnosis': diagnosis,
          'treatmentPlan': treatmentPlan,
          'maskingResult': maskingResult,
          'aiResult': aiResult,
          'doctorModifications': doctorModifications,
        }),
      );

      if (res.statusCode == 200) {
        // 업데이트 성공 후 최신 정보 다시 불러오기
        await fetchConsultationRecord(recordId);
        return true;
      } else {
        String message = '진료 기록 업데이트 실패 (Status: ${res.statusCode})';
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
        print('진료 기록 업데이트 중 네트워크 오류: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
