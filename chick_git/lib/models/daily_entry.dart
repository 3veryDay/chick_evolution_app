import 'dart:convert';

class ScheduleEvent {
  final String name;
  final String time;
  final String location;
  final bool isMeeting; // true: 회의, false: 일정

  ScheduleEvent({
    required this.name,
    required this.time,
    this.location = '',
    this.isMeeting = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'location': location,
      'isMeeting': isMeeting,
    };
  }

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      isMeeting: json['isMeeting'] ?? false,
    );
  }
}

class DailyEntry {
  final DateTime date;
  final List<ScheduleEvent> scheduleEvents; // 일정 정리 (일정/회의)
  final String dailyWork; // 오늘 하루 한 일
  final String mistakes; // 실수한 것
  final String learned; // 배운 것
  final String extraNotes; // 추가 메모

  DailyEntry({
    required this.date,
    List<ScheduleEvent>? scheduleEvents,
    this.dailyWork = '',
    this.mistakes = '',
    this.learned = '',
    this.extraNotes = '',
  }) : scheduleEvents = scheduleEvents ?? [];

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'scheduleEvents': scheduleEvents.map((e) => e.toJson()).toList(),
      'dailyWork': dailyWork,
      'mistakes': mistakes,
      'learned': learned,
      'extraNotes': extraNotes,
    };
  }

  // JSON에서 객체 생성
  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: DateTime.parse(json['date']),
      scheduleEvents: (json['scheduleEvents'] as List<dynamic>?)
          ?.map((e) => ScheduleEvent.fromJson(e))
          .toList(),
      dailyWork: json['dailyWork'] ?? '',
      mistakes: json['mistakes'] ?? '',
      learned: json['learned'] ?? '',
      extraNotes: json['extraNotes'] ?? '',
    );
  }

  // 복사본 생성 (업데이트용)
  DailyEntry copyWith({
    DateTime? date,
    List<ScheduleEvent>? scheduleEvents,
    String? dailyWork,
    String? mistakes,
    String? learned,
    String? extraNotes,
  }) {
    return DailyEntry(
      date: date ?? this.date,
      scheduleEvents: scheduleEvents ?? this.scheduleEvents,
      dailyWork: dailyWork ?? this.dailyWork,
      mistakes: mistakes ?? this.mistakes,
      learned: learned ?? this.learned,
      extraNotes: extraNotes ?? this.extraNotes,
    );
  }

  // 비어있는지 확인
  bool get isEmpty =>
      scheduleEvents.isEmpty &&
      dailyWork.isEmpty &&
      mistakes.isEmpty &&
      learned.isEmpty &&
      extraNotes.isEmpty;

  // 일정이 있는지 확인
  bool get hasSchedule => scheduleEvents.isNotEmpty;
}
