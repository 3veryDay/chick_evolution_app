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
  final _dailyWorkController = TextEditingController();
  final _mistakesController = TextEditingController();
  final _learnedController = TextEditingController();
  final _extraNotesController = TextEditingController();

  List<ScheduleEvent> _scheduleEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  @override
  void dispose() {
    _dailyWorkController.dispose();
    _mistakesController.dispose();
    _learnedController.dispose();
    _extraNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    final entry = await _storageService.getEntry(widget.date);

    if (entry != null) {
      _scheduleEvents = List.from(entry.scheduleEvents);
      _dailyWorkController.text = entry.dailyWork;
      _mistakesController.text = entry.mistakes;
      _learnedController.text = entry.learned;
      _extraNotesController.text = entry.extraNotes;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    final entry = DailyEntry(
      date: widget.date,
      scheduleEvents: _scheduleEvents,
      dailyWork: _dailyWorkController.text.trim(),
      mistakes: _mistakesController.text.trim(),
      learned: _learnedController.text.trim(),
      extraNotes: _extraNotesController.text.trim(),
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

  void _addScheduleEvent(bool isMeeting) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleEventDialog(
        isMeeting: isMeeting,
        onSave: (event) {
          setState(() {
            _scheduleEvents.add(event);
          });
        },
      ),
    );
  }

  void _editScheduleEvent(int index) {
    showDialog(
      context: context,
      builder: (context) => _ScheduleEventDialog(
        isMeeting: _scheduleEvents[index].isMeeting,
        initialEvent: _scheduleEvents[index],
        onSave: (event) {
          setState(() {
            _scheduleEvents[index] = event;
          });
        },
      ),
    );
  }

  void _deleteScheduleEvent(int index) {
    setState(() {
      _scheduleEvents.removeAt(index);
    });
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
            // 1. 일정 정리
            _buildScheduleSection(),
            const SizedBox(height: 16),

            // 2. 오늘 하루 한 일
            _buildTextSection(
              title: '오늘 하루 한 일',
              icon: Icons.check_circle_outline,
              controller: _dailyWorkController,
              hint: '오늘 완료한 업무들을 작성해주세요...\n\n예시:\n- 프로젝트 A 기획서 작성\n- 팀 미팅 참석\n- 코드 리뷰',
            ),
            const SizedBox(height: 16),

            // 3. 실수한 것
            _buildTextSection(
              title: '실수한 것',
              icon: Icons.warning_amber_outlined,
              controller: _mistakesController,
              hint: '오늘 실수했거나 아쉬웠던 점...\n\n예시:\n- 회의 시간 착각\n- 코드에서 버그 발생\n- 마감 기한 놓침',
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 16),

            // 4. 배운 것
            _buildTextSection(
              title: '배운 것',
              icon: Icons.school_outlined,
              controller: _learnedController,
              hint: '오늘 새롭게 배운 것들...\n\n예시:\n- Flutter 위젯 사용법\n- 효율적인 회의 진행법\n- 새로운 단축키',
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 16),

            // 5. 추가 메모
            _buildTextSection(
              title: '추가 메모',
              icon: Icons.edit_note,
              controller: _extraNotesController,
              hint: '자유롭게 작성해주세요...\n\n예시:\n- 내일 공부할 내용\n- 동료 생일\n- 개인 목표\n- 아이디어',
              color: Colors.purple.shade700,
            ),
            const SizedBox(height: 32),

            // 저장 버튼
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

  Widget _buildScheduleSection() {
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
                  Icons.event_note,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '일정 정리',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 일정/회의 추가 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addScheduleEvent(false),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('일정 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple.shade700,
                      side: BorderSide(color: Colors.purple.shade300),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addScheduleEvent(true),
                    icon: const Icon(Icons.groups, size: 20),
                    label: const Text('회의 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade300),
                    ),
                  ),
                ),
              ],
            ),

            // 등록된 일정 목록
            if (_scheduleEvents.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._scheduleEvents.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return _buildScheduleEventItem(event, index);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleEventItem(ScheduleEvent event, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: event.isMeeting
            ? Colors.blue.shade50
            : Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: event.isMeeting
              ? Colors.blue.shade200
              : Colors.purple.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            event.isMeeting ? Icons.groups : Icons.event,
            color: event.isMeeting
                ? Colors.blue.shade700
                : Colors.purple.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (event.location.isNotEmpty)
                  Text(
                    '📍 ${event.location}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 18, color: Colors.grey.shade600),
            onPressed: () => _editScheduleEvent(index),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
            onPressed: () => _deleteScheduleEvent(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    Color? color,
  }) {
    final sectionColor = color ?? Colors.amber.shade700;

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
                Icon(icon, color: sectionColor, size: 24),
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
              maxLines: 6,
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
                  borderSide: BorderSide(color: sectionColor, width: 2),
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

// 일정/회의 등록 다이얼로그
class _ScheduleEventDialog extends StatefulWidget {
  final bool isMeeting;
  final ScheduleEvent? initialEvent;
  final Function(ScheduleEvent) onSave;

  const _ScheduleEventDialog({
    required this.isMeeting,
    this.initialEvent,
    required this.onSave,
  });

  @override
  State<_ScheduleEventDialog> createState() => _ScheduleEventDialogState();
}

class _ScheduleEventDialogState extends State<_ScheduleEventDialog> {
  late TextEditingController _nameController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialEvent?.name ?? '');
    _timeController = TextEditingController(text: widget.initialEvent?.time ?? '');
    _locationController = TextEditingController(text: widget.initialEvent?.location ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요')),
      );
      return;
    }

    final event = ScheduleEvent(
      name: _nameController.text.trim(),
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      isMeeting: widget.isMeeting,
    );

    widget.onSave(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMeeting ? '회의 등록' : '일정 등록';
    final color = widget.isMeeting ? Colors.blue : Colors.purple;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isMeeting ? Icons.groups : Icons.event,
            color: color.shade700,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름 *',
                hintText: widget.isMeeting ? '예: 팀 주간 회의' : '예: 고객사 미팅',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: '시간',
                hintText: '예: 14:00 - 15:00',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '장소',
                hintText: '예: 3층 회의실',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.shade400,
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}
