import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';
import 'main_screen.dart';
import 'focus_time_tone_screen.dart';
import 'break_time_tone_screen.dart';
import '../providers/auth_provider.dart';

class SettingsScreenView extends ConsumerStatefulWidget {
  const SettingsScreenView({super.key});

  @override
  ConsumerState<SettingsScreenView> createState() => _SettingsScreenViewState();
}

class _SettingsScreenViewState extends ConsumerState<SettingsScreenView> {
  late TextEditingController _taskController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: ref.read(settingsProvider).currentTask);
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF070D24),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'What are we working on?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 40.0),
                    child: Text(
                      'Capture your intent. Let the focus follow.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF322D2D)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withAlpha(30)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.edit_note, size: 32, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a task name...',
                          hintStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update task name ONLY when hitting Start to prevent cursor jumping on web
                        ref.read(settingsProvider.notifier).updateCurrentTask(_taskController.text);
                        ref.read(timerProvider.notifier).startFromTask();
                        ref.read(navigationIndexProvider.notifier).setIndex(2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Row(
                        children: [
                          Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  const Icon(Icons.notifications_none, size: 28, color: Color(0xFF5E35B1)),
                  const SizedBox(width: 12),
                  const Text(
                    'Notification Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE), // Light blue background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _ToneSelectionItem(
                      title: 'Complete Focus Time Tone',
                      value: settings.focusTimeTone,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FocusTimeToneScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.withAlpha(50),
                      indent: 16,
                      endIndent: 16,
                    ),
                    _ToneSelectionItem(
                      title: 'Complete Break Time Tone',
                      value: settings.breakTimeTone,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BreakTimeToneScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(authLoadingProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


class _ToneSelectionItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ToneSelectionItem({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF070D24),
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
