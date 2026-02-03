import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import '../services/storage_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final StorageService _storageService = StorageService();
  int _completedDays = 0;
  String _evolutionStage = '알';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final days = await _storageService.getCompletedDaysCount();
    setState(() {
      _completedDays = days;
      _evolutionStage = _getEvolutionStage(days);
    });
  }

  String _getEvolutionStage(int days) {
    if (days < 7) return '알';
    if (days < 14) return '병아리';
    if (days < 30) return '닭';
    if (days < 60) return '독수리';
    return '불사조';
  }

  void _navigateToCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CalendarScreen()),
    );
    _loadProgress();
  }

  void _navigateToGoals() {
    // TODO: 목표 화면 구현 예정
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('목표 설정 기능은 곧 추가될 예정입니다!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 버튼 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 내 목표 버튼
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToGoals,
                      icon: const Icon(Icons.flag_outlined, size: 24),
                      label: const Text(
                        '내 목표',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.brown.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.brown.shade300,
                            width: 2,
                          ),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 달력 버튼
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToCalendar,
                      icon: const Icon(Icons.calendar_month, size: 24),
                      label: const Text(
                        '달력',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade400,
                        foregroundColor: Colors.brown.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 중앙 컨텐츠
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 진화 단계 텍스트
                    Text(
                      _evolutionStage,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 알 이미지
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.shade200,
                            Colors.amber.shade400,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getEvolutionEmoji(),
                          style: const TextStyle(fontSize: 100),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 진행 상황
                    Text(
                      '성장 일수: $_completedDays일',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEvolutionEmoji() {
    switch (_evolutionStage) {
      case '알':
        return '🥚';
      case '병아리':
        return '🐣';
      case '닭':
        return '🐔';
      case '독수리':
        return '🦅';
      case '불사조':
        return '🔥';
      default:
        return '🥚';
    }
  }
}
