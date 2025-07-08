// lib/features/doctor_portal/view/telemedicine_request_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart';

class TelemedicineRequestListScreen extends StatelessWidget {
  const TelemedicineRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진료 현황', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: const [
          // 앱 바의 알람 아이콘은 이미지에 없으므로 제거된 상태 유지
        ],
      ),
      body: Row( // ✅ Row 위젯을 사용하여 좌우 분할
        children: [
          // 좌측 진료 현황 목록 (Expanded로 남은 공간 차지)
          Expanded(
            flex: 3, // 좌측이 더 넓게 (예: 3:1 비율)
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildStatusSection(context, '진료중', Colors.orange, [
                  _buildRequestCard(context, '김철수', 'Wed, 18 Jul | 치아 지각 과민 (재진환자)', '진료중', 1),
                  _buildRequestCard(context, '이영희', 'Sun, 15 Jul | 충치 의심, 잇몸 통증 (초진환자)', '진료중', 2),
                ]),
                _buildStatusSection(context, '대기중', Colors.blue, [
                  _buildRequestCard(context, '박민수', 'Mon, 09 Jul | 사랑니 통증 (초진환자)', '대기중', 3),
                ]),
                _buildStatusSection(context, '완료됨', Colors.green, [
                  _buildRequestCard(context, '정미경', 'Thu, 12 Jul | 치아 시린 증상 (재진환자)', '완료됨', 4),
                  _buildRequestCard(context, '최지훈', 'Fri, 06 Jul | 임플란트 상담 요청 (초진환자)', '완료됨', 5),
                ]),
              ],
            ),
          ),
          // 우측 알람 및 추천 섹션
          Expanded(
            flex: 1, // 우측이 좁게 (예: 3:1 비율)
            child: Container(
              color: Colors.grey[100], // 배경색으로 구분
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 알람 섹션 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '알람',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.blueAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('알람 목록 보기 (미구현)')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded( // 알람 목록이 스크롤되도록 Expanded 사용
                    child: ListView(
                      children: [
                        _buildAlarmItem(context, '새로운 진료 신청: 김민수 (10:30)'),
                        _buildAlarmItem(context, '예약 변경: 이수진 (내일 14:00)'),
                        _buildAlarmItem(context, '시스템 업데이트 알림'),
                        // 더 많은 알람 항목 추가 가능
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 추천 섹션 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '추천',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.blueAccent),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('추천 정보 더보기 (미구현)')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded( // 추천 목록이 스크롤되도록 Expanded 사용
                    child: ListView(
                      children: [
                        _buildRecommendationItem(context, 'AI 진단 정확도 향상 팁'),
                        _buildRecommendationItem(context, '최신 치과 장비 소개'),
                        _buildRecommendationItem(context, '환자 만족도 높이는 방법'),
                        // 더 많은 추천 항목 추가 가능
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, String title, Color color, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            '$title (${cards.length})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        ...cards,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRequestCard(BuildContext context, String patientName, String details, String status, int consultationId) {
    Color statusColor;
    switch (status) {
      case '진료중':
        statusColor = Colors.orange;
        break;
      case '대기중':
        statusColor = Colors.blue;
        break;
      case '완료됨':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(details),
        trailing: Chip(
          label: Text(status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: statusColor,
        ),
        onTap: () {
          context.go('/telemedicine_detail/$consultationId');
        },
      ),
    );
  }

  // 알람 항목 위젯
  Widget _buildAlarmItem(BuildContext context, String message) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
        ),
      ),
    );
  }

  // 추천 항목 위젯
  Widget _buildRecommendationItem(BuildContext context, String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
        ),
      ),
    );
  }
}
