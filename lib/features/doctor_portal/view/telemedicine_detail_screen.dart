// lib/features/doctor_portal/view/telemedicine_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/doctor_portal/viewmodel/consultation_viewmodel.dart';
import 'package:t0703/features/doctor_portal/model/consultation_record.dart';
import 'package:t0703/features/patient/model/patient.dart'; // Patient 모델 임포트

class TelemedicineDetailScreen extends StatefulWidget {
  final int consultationId; // 진료 기록 ID를 인자로 받음

  const TelemedicineDetailScreen({required this.consultationId, super.key});

  @override
  State<TelemedicineDetailScreen> createState() => _TelemedicineDetailScreenState();
}

class _TelemedicineDetailScreenState extends State<TelemedicineDetailScreen> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _maskingResultController = TextEditingController();
  final TextEditingController _aiResultController = TextEditingController();
  final TextEditingController _treatmentPlanController = TextEditingController();
  final TextEditingController _chiefComplaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConsultationDetails();
    });
  }

  Future<void> _fetchConsultationDetails() async {
    final consultationViewModel = context.read<ConsultationViewModel>();
    await consultationViewModel.fetchConsultationRecord(widget.consultationId);
    if (consultationViewModel.currentConsultation != null) {
      _diagnosisController.text = consultationViewModel.currentConsultation!.diagnosis ?? '';
      _maskingResultController.text = consultationViewModel.currentConsultation!.maskingResult ?? '';
      _aiResultController.text = consultationViewModel.currentConsultation!.aiResult ?? '';
      _treatmentPlanController.text = consultationViewModel.currentConsultation!.treatmentPlan ?? '';
      _chiefComplaintController.text = consultationViewModel.currentConsultation!.chiefComplaint ?? '';
    }
  }

  Future<void> _saveConsultation() async {
    final consultationViewModel = context.read<ConsultationViewModel>();
    final success = await consultationViewModel.updateConsultationRecord(
      recordId: widget.consultationId,
      chiefComplaint: _chiefComplaintController.text,
      diagnosis: _diagnosisController.text,
      treatmentPlan: _treatmentPlanController.text,
      maskingResult: _maskingResultController.text,
      aiResult: _aiResultController.text,
      doctorModifications: _diagnosisController.text, // 의사 수정 내용은 진단 내용으로 임시 사용
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('진료 기록이 성공적으로 저장되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('진료 기록 저장 실패: ${consultationViewModel.errorMessage}')),
      );
    }
  }

  void _resetConsultation() {
    // 현재 불러온 데이터로 초기화
    final consultation = context.read<ConsultationViewModel>().currentConsultation;
    setState(() {
      _diagnosisController.text = consultation?.diagnosis ?? '';
      _maskingResultController.text = consultation?.maskingResult ?? '';
      _aiResultController.text = consultation?.aiResult ?? '';
      _treatmentPlanController.text = consultation?.treatmentPlan ?? '';
      _chiefComplaintController.text = consultation?.chiefComplaint ?? '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('진단 내용이 초기화되었습니다.')),
    );
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _maskingResultController.dispose();
    _aiResultController.dispose();
    _treatmentPlanController.dispose();
    _chiefComplaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConsultationViewModel>(
      builder: (context, consultationViewModel, child) {
        final record = consultationViewModel.currentConsultation;
        final patientInfo = record?.patientInfo;

        if (consultationViewModel.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (consultationViewModel.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('진료 상세')),
            body: Center(child: Text('오류: ${consultationViewModel.errorMessage}')),
          );
        }

        if (record == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('진료 상세')),
            body: const Center(child: Text('오류: 진료 기록을 찾을 수 없습니다. 유효한 진료 ID인지 확인해주세요.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${patientInfo?.name ?? '환자'} 진료 상세',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 환자 구강 이미지 섹션
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('환자 구강 이미지', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Center(
                          child: Image.asset(
                            'assets/images/image_3991dd.jpg', // 이미지 경로 확인
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('마스킹 결과', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _maskingResultController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '마스킹 결과가 여기에 표시됩니다.',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true, // 의사가 수정할 수 없는 필드로 설정
                        ),
                        const SizedBox(height: 16),
                        Text('AI 진단 결과', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _aiResultController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'AI 진단 결과가 여기에 표시됩니다.',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true, // 의사가 수정할 수 없는 필드로 설정
                        ),
                      ],
                    ),
                  ),
                ),
                // 환자 정보 섹션
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('환자 정보', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        _buildInfoRow('이름', patientInfo?.name ?? 'N/A'),
                        _buildInfoRow('생년월일', patientInfo?.dateOfBirth ?? 'N/A'),
                        _buildInfoRow('성별', patientInfo?.gender ?? 'N/A'),
                        _buildInfoRow('연락처', patientInfo?.phoneNumber ?? 'N/A'),
                        _buildInfoRow('주소', patientInfo?.address ?? 'N/A'),
                        // TODO: 차트 ID, 내원일, 방문목적 등 추가 정보는 ConsultationRecord 또는 Appointment에서 가져와야 함
                      ],
                    ),
                  ),
                ),
                // 의사 진단 및 수정 섹션
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('진료 내용 및 수정', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Text('주소 (Chief Complaint)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _chiefComplaintController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '환자의 주된 불편사항을 입력하세요.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('진단 (Diagnosis)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _diagnosisController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: '진단 내용을 입력하세요...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('치료 계획 (Treatment Plan)', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _treatmentPlanController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: '치료 계획을 입력하세요...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _resetConsultation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('초기화'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _saveConsultation,
                              icon: const Icon(Icons.save),
                              label: const Text('저장하기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 100, // 라벨 너비 조정
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
