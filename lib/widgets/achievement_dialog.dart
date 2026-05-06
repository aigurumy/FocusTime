import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/achievement_provider.dart';
import '../providers/timer_provider.dart';
import '../screens/main_screen.dart';

class AchievementDialog extends ConsumerStatefulWidget {
  final String topic;
  final int durationMinutes;

  const AchievementDialog({
    super.key,
    required this.topic,
    required this.durationMinutes,
  });

  @override
  ConsumerState<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends ConsumerState<AchievementDialog> {
  final TextEditingController _logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Play the focus completion tone when the dialog appears
    Future.microtask(() {
      ref.read(timerProvider.notifier).playSelectedTone(TimerMode.focus);
    });
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _submitAchievement() {
    final logText = _logController.text.trim();
    if (logText.isNotEmpty) {
      final achievement = Achievement(
        topic: widget.topic,
        log: logText,
        durationMinutes: widget.durationMinutes,
        timestamp: DateTime.now(),
      );
      ref.read(achievementProvider.notifier).addAchievement(achievement);
    }
    
    // Close dialog and switch to Break screen via state
    ref.read(timerProvider.notifier).setMode(TimerMode.shortBreak);
    ref.read(navigationIndexProvider.notifier).setIndex(2);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Focus Complete!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF070D24),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "You've successfully dedicated ${widget.durationMinutes} minutes to your goal. What did you achieve?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF607D8B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Topic: ${widget.topic}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0x99070D24),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Light mint green
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5D6A7), width: 1),
                ),
                child: TextField(
                  controller: _logController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF070D24),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Finish design UI/UX',
                    hintStyle: TextStyle(color: Color(0xFF90A4AE)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitAchievement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC), // Teal green
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFF4DB6AC).withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Log Achievement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(timerProvider.notifier).setMode(TimerMode.shortBreak);
                  ref.read(navigationIndexProvider.notifier).setIndex(2);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0x99070D24),
                ),
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
