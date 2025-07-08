// lib/features/patient/view/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:t0703/features/patient/model/patient.dart';
import 'package:t0703/features/patient/viewmodel/patient_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/consultation_viewmodel.dart';
import 'package:t0703/features/doctor_portal/model/consultation_record.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart'; // 현재 로그인 의사 ID를 위해 임포트

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({required this.patientId, super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  List<ConsultationRecord> _consultations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPatientAndConsultations();
    });
  }

  Future<void> _fetchPatientAndConsultations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final patientViewModel = context.read<PatientViewModel>();
    final consultationViewModel = context.read<ConsultationViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    try {
      // 1. 환자 정보 가져오기
      await patientViewModel.fetchPatient(widget.patientId); // PatientViewModel에 fetchPatient 메서드 추가 필요
      if (patientViewModel.errorMessage != null) {
        throw Exception(patientViewModel.errorMessage);
      }
      _patient = patientViewModel.currentPatient; // PatientViewModel에 currentPatient 추가 필요

      // 2. 해당 환자의 진료 기록 가져오기
      if (authViewModel.currentUser != null && authViewModel.currentUser!.isDoctor) {
        await consultationViewModel.fetchConsultationRecordsByPatient(
            widget.patientId, authViewModel.currentUser!.id); // ConsultationViewModel에 메서드 추가 필요
        if (consultationViewModel.errorMessage != null) {
          throw Exception(consultationViewModel.errorMessage);
        }
        _consultations = consultationViewModel.patientConsultations; // ConsultationViewModel에 patientConsultations 추가 필요
      } else {
        throw Exception('의사 계정으로 로그인해야 환자 진료 기록을 볼 수 있습니다.');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('환자 상세 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('환자 상세 정보')),
        body: Center(child: Text('오류: $_errorMessage')),
      );
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('환자 상세 정보')),
        body: const Center(child: Text('환자 정보를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_patient!.name} 환자 상세 정보', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환자 기본 정보 섹션
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('환자 기본 정보', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    _buildInfoRow('이름', _patient!.name),
                    _buildInfoRow('생년월일', _patient!.dateOfBirth),
                    _buildInfoRow('성별', _patient!.gender),
                    _buildInfoRow('연락처', _patient!.phoneNumber ?? 'N/A'),
                    _buildInfoRow('주소', _patient!.address ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('진료 기록', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            _consultations.isEmpty
                ? const Center(child: Text('등록된 진료 기록이 없습니다.'))
                : ListView.builder(
                    shrinkWrap: true, // ListView가 Column 내에서 스크롤 가능하도록
                    physics: const NeverScrollableScrollPhysics(), // 부모 스크롤과 충돌 방지
                    itemCount: _consultations.length,
                    itemBuilder: (context, index) {
                      final record = _consultations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text('${record.consultationDate} ${record.consultationTime}'),
                          subtitle: Text('주소: ${record.chiefComplaint ?? '없음'}'),
                          onTap: () {
                            // 특정 진료 기록 상세 화면으로 이동
                            context.go('/telemedicine_detail/${record.id}');
                          },
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
