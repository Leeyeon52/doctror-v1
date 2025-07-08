// lib/features/doctor_portal/view/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 임포트
import 'package:t0703/features/doctor_portal/viewmodel/appointment_viewmodel.dart'; // AppointmentViewModel 임포트
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart'; // AuthViewModel 임포트 (의사 ID)
import 'package:t0703/features/patient/viewmodel/patient_viewmodel.dart'; // PatientViewModel 임포트 (환자 목록)
import 'package:t0703/features/doctor_portal/model/appointment.dart'; // Appointment 모델 임포트
import 'package:t0703/features/patient/model/patient.dart'; // Patient 모델 임포트

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAppointmentsForSelectedDay();
      context.read<PatientViewModel>().fetchPatients(
          context.read<AuthViewModel>().currentUser?.id ?? 0); // 의사 ID로 환자 목록 불러오기
    });
  }

  Future<void> _fetchAppointmentsForSelectedDay() async {
    final authViewModel = context.read<AuthViewModel>();
    final appointmentViewModel = context.read<AppointmentViewModel>();

    if (authViewModel.currentUser != null && authViewModel.currentUser!.isDoctor) {
      final doctorId = authViewModel.currentUser!.id;
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      await appointmentViewModel.fetchAppointmentsByDate(doctorId, formattedDate);
      if (appointmentViewModel.errorMessage != null) {
        _showSnack('예약 로드 오류: ${appointmentViewModel.errorMessage}');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
        backgroundColor: Colors.blueGrey[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentViewModel = context.watch<AppointmentViewModel>();
    final patientViewModel = context.watch<PatientViewModel>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('진료 캘린더', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchAppointmentsForSelectedDay(); // 선택된 날짜의 예약 불러오기
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _fetchAppointmentsForSelectedDay(); // 페이지 변경 시 예약 새로고침
            },
            eventLoader: (day) {
              // 캘린더에 표시할 이벤트 (예약이 있는 날짜에 점 표시)
              final formattedDay = DateFormat('yyyy-MM-dd').format(day);
              final appointments = appointmentViewModel.appointments
                  .where((appt) => appt.appointmentDate == formattedDay)
                  .toList();
              return appointments.isNotEmpty ? ['event'] : []; // 이벤트가 있으면 'event' 반환
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red[300],
                shape: BoxShape.circle,
              ),
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blueAccent),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blueAccent),
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDay!),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAppointmentDialog(context, authViewModel.currentUser?.id, patientViewModel.patients),
                  icon: const Icon(Icons.add),
                  label: const Text('예약 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: appointmentViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointmentViewModel.errorMessage != null
                    ? Center(child: Text('오류: ${appointmentViewModel.errorMessage}'))
                    : appointmentViewModel.appointments.isEmpty
                        ? const Center(child: Text('선택된 날짜에 예약이 없습니다.'))
                        : ListView.builder(
                            itemCount: appointmentViewModel.appointments.length,
                            itemBuilder: (context, index) {
                              final appt = appointmentViewModel.appointments[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                elevation: 2,
                                child: ListTile(
                                  leading: const Icon(Icons.event),
                                  title: Text('${appt.appointmentTime} - ${appt.patientName}'),
                                  subtitle: Text('상태: ${appt.status} ${appt.notes != null && appt.notes!.isNotEmpty ? '| ${appt.notes}' : ''}'),
                                  onTap: () => _showAppointmentDialog(context, authViewModel.currentUser?.id, patientViewModel.patients, appointment: appt),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () async {
                                      final confirmDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('예약 삭제'),
                                          content: Text('${appt.patientName} 님의 ${appt.appointmentDate} ${appt.appointmentTime} 예약을 삭제하시겠습니까?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                                          ],
                                        ),
                                      );
                                      if (confirmDelete == true) {
                                        final success = await appointmentViewModel.deleteAppointment(
                                          appt.id,
                                          authViewModel.currentUser!.id,
                                          appt.appointmentDate,
                                        );
                                        if (success) {
                                          _showSnack('예약이 삭제되었습니다.');
                                        } else {
                                          _showSnack('예약 삭제 실패: ${appointmentViewModel.errorMessage}');
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  // 예약 추가/수정 다이얼로그
  void _showAppointmentDialog(
    BuildContext context,
    int? doctorId,
    List<Patient> patients, {
    Appointment? appointment, // 수정 시 기존 예약 정보
  }) {
    if (doctorId == null) {
      _showSnack('의사 ID를 찾을 수 없습니다. 다시 로그인해주세요.');
      return;
    }
    if (patients.isEmpty) {
      _showSnack('먼저 환자 목록을 추가해주세요.');
      return;
    }

    final isEditing = appointment != null;
    Patient? selectedPatient = isEditing
        ? patients.firstWhere((p) => p.id == appointment.patientId, orElse: () => patients.first)
        : patients.first;
    final TextEditingController dateController = TextEditingController(
        text: isEditing ? appointment.appointmentDate : DateFormat('yyyy-MM-dd').format(_selectedDay!));
    final TextEditingController timeController = TextEditingController(
        text: isEditing ? appointment.appointmentTime : DateFormat('HH:mm').format(DateTime.now()));
    final TextEditingController notesController = TextEditingController(text: appointment?.notes ?? '');
    String selectedStatus = appointment?.status ?? '대기중';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // 다이얼로그 내에서 상태 변경을 위해 StatefulBuilder 사용
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? '예약 수정' : '새 예약 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Patient>(
                      value: selectedPatient,
                      decoration: const InputDecoration(labelText: '환자 선택'),
                      items: patients.map((patient) {
                        return DropdownMenuItem(
                          value: patient,
                          child: Text(patient.name),
                        );
                      }).toList(),
                      onChanged: (Patient? newValue) {
                        setState(() {
                          selectedPatient = newValue;
                        });
                      },
                    ),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: '날짜 (YYYY-MM-DD)'),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(dateController.text),
                          firstDate: DateTime.utc(2020, 1, 1),
                          lastDate: DateTime.utc(2030, 12, 31),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: '시간 (HH:MM)'),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            timeController.text =
                                '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: '상태'),
                      items: <String>['대기중', '진료중', '완료됨', '취소됨']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStatus = newValue!;
                        });
                      },
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: '메모'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final appointmentViewModel = context.read<AppointmentViewModel>();
                    bool success;
                    if (isEditing) {
                      success = await appointmentViewModel.updateAppointment(
                        appointmentId: appointment!.id,
                        doctorId: doctorId,
                        originalDate: appointment.appointmentDate,
                        appointmentDate: dateController.text,
                        appointmentTime: timeController.text,
                        status: selectedStatus,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                    } else {
                      success = await appointmentViewModel.addAppointment(
                        patientId: selectedPatient!.id,
                        doctorId: doctorId,
                        appointmentDate: dateController.text,
                        appointmentTime: timeController.text,
                        status: selectedStatus,
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      );
                    }

                    if (Navigator.of(dialogContext).canPop()) {
                      Navigator.of(dialogContext).pop();
                    }

                    if (success) {
                      _showSnack(isEditing ? '예약이 수정되었습니다!' : '새로운 예약이 추가되었습니다!');
                      _fetchAppointmentsForSelectedDay(); // 예약 목록 새로고침
                    } else {
                      _showSnack(isEditing
                          ? '예약 수정 실패: ${appointmentViewModel.errorMessage}'
                          : '예약 추가 실패: ${appointmentViewModel.errorMessage}');
                    }
                  },
                  child: Text(isEditing ? '수정' : '추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
