import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_entry.dart';
import '../services/storage_service.dart';

class EntryDetailScreen extends StatefulWidget {
  final DateTime date;

  const EntryDetailScreen({
    super.key,
    required this.date,
  });

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final StorageService _storageService = StorageService();
  final _retrospectiveController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _meetingController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  @override
  void dispose() {
    _retrospectiveController.dispose();
    _scheduleController.dispose();
    _meetingController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    final entry = await _storageService.getEntry(widget.date);
    
    if (entry != null) {
      _retrospectiveController.text = entry.retrospective;
      _scheduleController.text = entry.schedule;
      _meetingController.text = entry.meeting;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    final entry = DailyEntry(
      date: widget.date,
      retrospective: _retrospectiveController.text.trim(),
      schedule: _scheduleController.text.trim(),
      meeting: _meetingController.text.trim(),
    );

    await _storageService.saveEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장되었습니다'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy년 MM월 dd일 (E)').format(widget.date);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: Text(dateStr),
        backgroundColor: Colors.amber.shade400,
        foregroundColor: Colors.brown.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
            tooltip: '저장',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: '회고',
              icon: Icons.lightbulb_outline,
              controller: _retrospectiveController,
              hint: '오늘 하루를 돌아보며...\n\n- 잘한 점\n- 배운 점\n- 개선할 점',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '일정 정리',
              icon: Icons.event_note,
              controller: _scheduleController,
              hint: '오늘의 일정과 내일 할 일...\n\n- 완료한 업무\n- 진행 중인 업무\n- 예정된 업무',
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: '회의 정리',
              icon: Icons.groups,
              controller: _meetingController,
              hint: '참석한 회의 내용...\n\n- 회의 주제\n- 주요 결정사항\n- 액션 아이템',
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade400,
                  foregroundColor: Colors.brown.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.brown.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.brown.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.amber.shade600,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
