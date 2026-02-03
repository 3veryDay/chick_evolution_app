import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry.dart';
import '../services/storage_service.dart';
import 'entry_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  DateTime _selectedMonth = DateTime.now();
  Map<String, DailyEntry> _entries = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _storageService.loadEntries();
    setState(() {
      _entries = entries;
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _onDayTapped(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailScreen(date: date),
      ),
    );
    _loadEntries();
  }

  bool _hasEntry(DateTime date) {
    final dateKey = _formatDateKey(date);
    return _entries.containsKey(dateKey);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text('내 성장 기록'),
        backgroundColor: Colors.amber.shade400,
        foregroundColor: Colors.brown.shade900,
      ),
      body: Column(
        children: [
          // 월 선택 헤더
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 32),
                  onPressed: _previousMonth,
                  color: Colors.brown.shade700,
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(_selectedMonth),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 32),
                  onPressed: _nextMonth,
                  color: Colors.brown.shade700,
                ),
              ],
            ),
          ),

          // 요일 헤더
          _buildWeekdayHeader(),

          // 달력 그리드 (화면 꽉 채우기)
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: weekdays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final isWeekend = index >= 5; // 토, 일
          
          return Expanded(
            flex: isWeekend ? 1 : 2, // 주말은 평일의 0.5 너비
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isWeekend ? Colors.red.shade400 : Colors.brown.shade700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // 해당 월의 첫날과 마지막 날
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    // 첫 주 시작일 (월요일 기준)
    final startDay = firstDayOfMonth.subtract(
      Duration(days: (firstDayOfMonth.weekday - 1) % 7),
    );

    // 6주 고정 (화면 꽉 채우기 위해 Column + Expanded 사용)
    return Column(
      children: List.generate(6, (weekIndex) {
        return Expanded(
          child: _buildWeekRow(weekIndex, startDay, lastDayOfMonth),
        );
      }),
    );
  }

  Widget _buildWeekRow(int weekIndex, DateTime startDay, DateTime lastDayOfMonth) {
    final weekStart = startDay.add(Duration(days: weekIndex * 7));
    
    return Row(
      children: List.generate(7, (dayIndex) {
        final date = weekStart.add(Duration(days: dayIndex));
        final isWeekend = dayIndex >= 5;
        final isCurrentMonth = date.month == _selectedMonth.month;
        final isToday = _isToday(date);
        final hasEntry = _hasEntry(date);

        // 빈 공간 처리 (다음 달 날짜가 캘린더 범위를 벗어난 경우)
        if (!isCurrentMonth && date.isAfter(lastDayOfMonth)) {
          return Expanded(
            flex: isWeekend ? 1 : 2,
            child: Container(),
          );
        }

        return Expanded(
          flex: isWeekend ? 1 : 2,
          child: _buildDayCell(
            date,
            isCurrentMonth,
            isToday,
            hasEntry,
            isWeekend,
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    bool isCurrentMonth,
    bool isToday,
    bool hasEntry,
    bool isWeekend,
  ) {
    // Null 에러 방지를 위한 안전한 접근
    final entry = isCurrentMonth && hasEntry ? _entries[_formatDateKey(date)] : null;
    final scheduleEvents = entry?.scheduleEvents ?? [];
    final scheduleCount = scheduleEvents.length;

    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTapped(date) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? Colors.amber.shade300
              : hasEntry
                  ? Colors.green.shade50
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? Colors.brown.shade700
                : Colors.brown.shade200,
            width: isToday ? 2 : 1,
          ),
        ),
        // Stack이 Container 크기를 꽉 채우도록 설정
        child: Stack(
          fit: StackFit.expand, 
          children: [
            // 1. 날짜 (왼쪽 위)
            Positioned(
              top: 4,
              left: 4,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: !isCurrentMonth
                      ? Colors.grey.shade400
                      : isWeekend
                          ? Colors.red.shade600
                          : Colors.brown.shade900,
                ),
              ),
            ),
            
            // 2. 일정 텍스트 표시 (원하시는 기능!)
            if (scheduleCount > 0)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: scheduleEvents.take(2).map((event) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: event.isMeeting
                            ? Colors.blue.shade100
                            : Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 9, // 글자 크기 조정
                          color: event.isMeeting
                              ? Colors.blue.shade900
                              : Colors.purple.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 3. 더 많은 일정 표시 (+N)
            if (scheduleCount > 2)
              Positioned(
                bottom: 2,
                right: 2,
                child: Text(
                  '+${scheduleCount - 2}',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
            // 4. 작성 완료 표시 (우측 상단 초록 점)
            if (hasEntry)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}