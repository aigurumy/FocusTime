import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/timer_provider.dart';
import 'main_screen.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Setting',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D72D9),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What are we working on?',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Capture your intent. Let the focus follow.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
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
                  const Icon(Icons.tune, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'App Settings',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _DurationCard(
                title: 'Focus Duration',
                subtitle: 'The length of your deep work session.',
                value: settings.focusDuration,
                onChanged: (val) {
                  settingsNotifier.updateFocusDuration(val.toInt());
                },
              ),
              const SizedBox(height: 16),

              _DurationCard(
                title: 'Break Duration',
                subtitle: 'A quiet moment to recharge.',
                value: settings.breakDuration,
                onChanged: (val) {
                  settingsNotifier.updateBreakDuration(val.toInt());
                },
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withAlpha(30)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Preferences',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'A quiet moment to recharge.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    _ToggleCard(
                      icon: Icons.notifications_none,
                      title: 'Background Rain Sound',
                      subtitle: 'Play sound during focus mode',
                      value: settings.rainSoundEnabled,
                      onChanged: (val) {
                        settingsNotifier.toggleRainSound(val);
                      },
                    ),
                    const SizedBox(height: 12),

                    _ToggleCard(
                      icon: Icons.remove_circle_outline,
                      title: 'Deep Work Shield',
                      subtitle: 'Auto-silence all system alerts\n(Requires PWA)',
                      value: settings.deepWorkShieldEnabled,
                      onChanged: (val) {
                        settingsNotifier.toggleDeepWorkShield(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<double> onChanged;

  const _DurationCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA), // Light cyan
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value}m',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006064), // Dark cyan
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFB39DDB), // Light purple
              inactiveTrackColor: const Color(0xFFEDE7F6),
              thumbColor: const Color(0xFF9575CD),
              overlayColor: const Color(0xFF9575CD).withAlpha(50),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 60,
              onChanged: onChanged,
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1m', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              Text('60m', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE1F5FE), // Light blue
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5E35B1)), // Purple icon
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF5E35B1),
            activeTrackColor: const Color(0xFFD1C4E9),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withAlpha(100),
          ),
        ],
      ),
    );
  }
}
