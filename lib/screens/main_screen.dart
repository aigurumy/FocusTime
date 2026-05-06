import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_screen.dart';
import 'insight_screen.dart';
import 'setting_screen.dart';
import 'goal_screen.dart';
import 'profile_screen.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goal_provider.dart';
import '../widgets/achievement_dialog.dart';
import '../widgets/break_completion_dialog.dart';
import 'break_screen.dart';


class NavigationState {
  final int index;
  final bool scrollToBottom;
  NavigationState({required this.index, this.scrollToBottom = false});
}

class NavigationIndexNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() => NavigationState(index: 2); // Default to Focus page

  void setIndex(int index, {bool scrollToBottom = false}) {
    state = NavigationState(index: index, scrollToBottom: scrollToBottom);
  }

  void clearScrollFlag() {
    state = NavigationState(index: state.index, scrollToBottom: false);
  }
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, NavigationState>(() {
  return NavigationIndexNotifier();
});

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global listener for timer completion to show achievement dialog on any page
    ref.listen<TimerState>(timerProvider, (previous, next) {
      if (previous?.remainingSeconds != 0 && next.remainingSeconds == 0 && next.mode == TimerMode.focus && next.initialSeconds > 0) {
        final currentSettings = ref.read(settingsProvider);
        final taskName = currentSettings.currentTask.isEmpty ? 'My Focus Task' : currentSettings.currentTask;
        final focusMinutes = next.initialSeconds ~/ 60;

        // Log focus minutes to matching goal
        final goals = ref.read(activeGoalsProvider);
        for (final goal in goals) {
          if (goal.name == taskName) {
            ref.read(goalProvider.notifier).logFocusMinutes(goal.id, focusMinutes);
            break;
          }
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AchievementDialog(
            topic: taskName,
            durationMinutes: focusMinutes,
          ),
        );
      }

      // Show Break Completion Dialog
      if (previous?.remainingSeconds != 0 && 
          next.remainingSeconds == 0 && 
          (next.mode == TimerMode.shortBreak || next.mode == TimerMode.longBreak) && 
          next.initialSeconds > 0) {

        // Reset to Focus mode and ensure we're on the Focus tab
        ref.read(timerProvider.notifier).setMode(TimerMode.focus);
        ref.read(navigationIndexProvider.notifier).setIndex(2);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const BreakCompletionDialog(),
        );
      }
    });

    final navState = ref.watch(navigationIndexProvider);
    final currentIndex = navState.index;
    final timerState = ref.watch(timerProvider);

    final List<Widget> screens = [
      const InsightScreen(),
      const GoalScreen(),
      (timerState.mode == TimerMode.shortBreak || timerState.mode == TimerMode.longBreak) ? const BreakScreen() : const TimerScreen(), // Focus page
      const SettingsScreenView(), // Setting page
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFF32E77),
          unselectedItemColor: const Color(0xFFFA74C2),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Insight',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_rounded),
              label: 'Goal',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.schedule, 
                    size: 34, // Increased from 32
                    color: currentIndex == 2 ? const Color(0xFFF32E77) : const Color(0xFFFA74C2),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded, 
                        size: 19, // Increased from 18
                        color: currentIndex == 2 ? const Color(0xFFF32E77) : const Color(0xFFFA74C2),
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Focus',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Setting',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
