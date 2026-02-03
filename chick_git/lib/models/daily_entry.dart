import 'dart:convert';

class DailyEntry {
  final DateTime date;
  final String retrospective; // 회고
  final String schedule; // 일정 정리
  final String meeting; // 회의 정리

  DailyEntry({
    required this.date,
    this.retrospective = '',
    this.schedule = '',
    this.meeting = '',
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'retrospective': retrospective,
      'schedule': schedule,
      'meeting': meeting,
    };
  }

  // JSON에서 객체 생성
  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: DateTime.parse(json['date']),
      retrospective: json['retrospective'] ?? '',
      schedule: json['schedule'] ?? '',
      meeting: json['meeting'] ?? '',
    );
  }

  // 복사본 생성 (업데이트용)
  DailyEntry copyWith({
    DateTime? date,
    String? retrospective,
    String? schedule,
    String? meeting,
  }) {
    return DailyEntry(
      date: date ?? this.date,
      retrospective: retrospective ?? this.retrospective,
      schedule: schedule ?? this.schedule,
      meeting: meeting ?? this.meeting,
    );
  }

  // 비어있는지 확인
  bool get isEmpty =>
      retrospective.isEmpty && schedule.isEmpty && meeting.isEmpty;
}
