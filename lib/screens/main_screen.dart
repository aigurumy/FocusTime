import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_screen.dart';
import 'insight_screen.dart';
import 'setting_screen.dart';
import 'goal_screen.dart';

class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 2; // Default to Focus page

  void setIndex(int index) {
    state = index;
  }
}

final navigationIndexProvider = NotifierProvider<NavigationIndexNotifier, int>(() {
  return NavigationIndexNotifier();
});

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final List<Widget> screens = [
      const InsightScreen(),
      const GoalScreen(),
      const TimerScreen(), // Focus page
      const SettingsScreenView(), // Setting page
      const Center(child: Text("Profile Page")),
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
          selectedItemColor: currentIndex == 1 ? const Color(0xFF2879D9) : const Color(0xFFFF146E), // Blue for Goal, Deep pink for others
          unselectedItemColor: const Color(0xFFE91E63).withAlpha(150),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
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
              icon: Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.schedule, 
                      size: 28,
                      color: currentIndex == 2 ? const Color(0xFFFF146E) : const Color(0xFFE91E63).withAlpha(150),
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
                          size: 16, 
                          color: currentIndex == 2 ? const Color(0xFFFF146E) : const Color(0xFFE91E63).withAlpha(150),
                        ),
                      ),
                    ),
                  ],
                ),
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
