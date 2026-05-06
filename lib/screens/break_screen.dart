import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/progress_ring.dart';
import '../providers/goal_provider.dart';

class BreakScreen extends ConsumerStatefulWidget {
  const BreakScreen({super.key});

  @override
  ConsumerState<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends ConsumerState<BreakScreen> {
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final settings = ref.watch(settingsProvider);
    
    double progress = 1.0;
    if (timerState.initialSeconds > 0) {
      progress = timerState.remainingSeconds / timerState.initialSeconds;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final timerSize = (constraints.maxWidth * 0.72).clamp(200.0, 320.0);
            final timerFontSize = (timerSize * 0.25).clamp(48.0, 80.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    'Break Time',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF070D24),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Task Display Pill (Synced with Focus Session)
                  Builder(
                    builder: (ctx) {
                      final activeGoals = ref.watch(activeGoalsProvider);
                      final taskLabel = settings.currentTask.isEmpty
                          ? 'My Focus Task'
                          : settings.currentTask;

                      return GestureDetector(
                        onTap: () {
                          final RenderBox box = ctx.findRenderObject() as RenderBox;
                          final Offset offset = box.localToGlobal(Offset.zero);
                          final items = <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: '',
                              child: Text(
                                'My Focus Task',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (activeGoals.isNotEmpty)
                              const PopupMenuDivider(height: 8),
                            ...activeGoals.map((goal) => PopupMenuItem<String>(
                              value: goal.name,
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_rounded, size: 16, color: Color(0xFF00B8D4)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      goal.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ];

                          showMenu<String>(
                            context: ctx,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + box.size.height + 4,
                              offset.dx + box.size.width,
                              0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            color: Colors.white,
                            elevation: 6,
                            items: items,
                          ).then((selected) {
                            if (selected != null) {
                              ref.read(settingsProvider.notifier).updateCurrentTask(selected);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F7F9), // Very light cyan
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFFB2EBF2), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF26A69A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  taskLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF607D8B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF607D8B),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Circular Timer Display
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Gradient Ring background (static)
                        Container(
                          width: timerSize,
                          height: timerSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE0F7F9).withOpacity(0.5),
                              width: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: timerSize,
                          height: timerSize,
                          child: ProgressRing(
                            progress: progress,
                            color: const Color(0xFF00B8D4), // Cyan
                            strokeWidth: 20,
                          ),
                        ),
                        Text(
                          _formatTime(timerState.remainingSeconds),
                          style: TextStyle(
                            fontSize: timerFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Dynamic Slider
                  if (!timerState.isRunning && timerState.remainingSeconds == timerState.initialSeconds)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF4DB6AC),
                              inactiveTrackColor: const Color(0xFFB2EBF2),
                              thumbColor: const Color(0xFFB39DDB), // Light Purple
                              overlayColor: const Color(0xFFB39DDB).withOpacity(0.2),
                              trackHeight: 4.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            ),
                            child: Slider(
                              value: settings.breakDuration.toDouble(),
                              min: 1.0,
                              max: 60.0,
                              divisions: 59,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                ref.read(settingsProvider.notifier).updateBreakDuration(val.toInt());
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('1m', style: TextStyle(color: Color(0xFF0097A7), fontWeight: FontWeight.bold)),
                                Text('60m', style: TextStyle(color: Color(0xFF0097A7), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 72), // Maintain spacing when slider is hidden

                  const Spacer(flex: 1),

                  // Timer Controls
                  if (!timerState.isRunning && timerState.remainingSeconds == timerState.initialSeconds)
                    // Initial "Start Break Time" Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        timerNotifier.start();
                      },
                      child: Container(
                        width: 220,
                        height: 56,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4776E6), Color(0xFF8E54E9)], // Blue to Purple
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4776E6).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Start Break Time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    // Active State: Pause/Resume and Skip Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pause / Resume Button
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 147),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                if (timerState.isRunning) {
                                  timerNotifier.pause();
                                } else {
                                  timerNotifier.start();
                                }
                              },
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)], // Blue to Purple
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4776E6).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    timerState.isRunning ? 'Pause' : 'Resume',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Skip Break Button
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 147),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                timerNotifier.skip();
                              },
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF146E), Color(0xFFFFA0BC)], // Pink to Light Pink
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF146E).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Skip Break',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
