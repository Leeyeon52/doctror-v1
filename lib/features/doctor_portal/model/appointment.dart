// lib/features/doctor_portal/model/appointment.dart

class Appointment {
  final int id;
  final int patientId;
  final int doctorId;
  final String appointmentDate; // YYYY-MM-DD
  final String appointmentTime; // HH:MM
  final String status; // 예: '대기중', '진료중', '완료됨', '취소됨'
  final String? notes;
  final String? patientName; // API 응답에 포함될 환자 이름

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.appointmentTime,
    this.status = '대기중',
    this.notes,
    this.patientName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as int,
      patientId: json['patientId'] as int,
      doctorId: json['doctorId'] as int,
      appointmentDate: json['appointmentDate'] as String,
      appointmentTime: json['appointmentTime'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      patientName: json['patientName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'status': status,
      'notes': notes,
      'patientName': patientName,
    };
  }
}
