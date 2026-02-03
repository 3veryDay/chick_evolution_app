import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_entry.dart';

class StorageService {
  static const String _entriesKey = 'daily_entries';

  // 모든 엔트리 불러오기
  Future<Map<String, DailyEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_entriesKey);

    if (entriesJson == null) {
      return {};
    }

    final Map<String, dynamic> decoded = json.decode(entriesJson);
    final Map<String, DailyEntry> entries = {};

    decoded.forEach((key, value) {
      entries[key] = DailyEntry.fromJson(value);
    });

    return entries;
  }

  // 엔트리 저장
  Future<void> saveEntry(DailyEntry entry) async {
    final entries = await loadEntries();
    final dateKey = _formatDateKey(entry.date);
    
    if (entry.isEmpty) {
      entries.remove(dateKey);
    } else {
      entries[dateKey] = entry;
    }

    await _saveAllEntries(entries);
  }

  // 특정 날짜의 엔트리 불러오기
  Future<DailyEntry?> getEntry(DateTime date) async {
    final entries = await loadEntries();
    final dateKey = _formatDateKey(date);
    return entries[dateKey];
  }

  // 모든 엔트리 저장
  Future<void> _saveAllEntries(Map<String, DailyEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toEncode = {};

    entries.forEach((key, value) {
      toEncode[key] = value.toJson();
    });

    await prefs.setString(_entriesKey, json.encode(toEncode));
  }

  // 날짜를 키로 변환 (yyyy-MM-dd)
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 작성된 날짜 수 계산 (성장 단계 계산용)
  Future<int> getCompletedDaysCount() async {
    final entries = await loadEntries();
    return entries.length;
  }
}
