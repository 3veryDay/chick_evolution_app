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

          // 달력 그리드
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

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6, // 최대 6주
      itemBuilder: (context, weekIndex) {
        return _buildWeekRow(weekIndex, startDay, lastDayOfMonth);
      },
    );
  }

  Widget _buildWeekRow(int weekIndex, DateTime startDay, DateTime lastDayOfMonth) {
    final weekStart = startDay.add(Duration(days: weekIndex * 7));
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: List.generate(7, (dayIndex) {
          final date = weekStart.add(Duration(days: dayIndex));
          final isWeekend = dayIndex >= 5;
          final isCurrentMonth = date.month == _selectedMonth.month;
          final isToday = _isToday(date);
          final hasEntry = _hasEntry(date);

          if (!isCurrentMonth && date.isAfter(lastDayOfMonth)) {
            return Expanded(
              flex: isWeekend ? 1 : 2,
              child: const SizedBox(),
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
      ),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    bool isCurrentMonth,
    bool isToday,
    bool hasEntry,
    bool isWeekend,
  ) {
    return GestureDetector(
      onTap: isCurrentMonth ? () => _onDayTapped(date) : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? Colors.amber.shade300
              : hasEntry
                  ? Colors.green.shade100
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? Colors.brown.shade700
                : Colors.brown.shade200,
            width: isToday ? 2 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: !isCurrentMonth
                      ? Colors.grey.shade400
                      : isWeekend
                          ? Colors.red.shade600
                          : Colors.brown.shade900,
                ),
              ),
              if (hasEntry)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
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
