import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart'; // Add this for navigationIndexProvider
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/goal_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/achievement_dialog.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final achievements = ref.watch(achievementProvider);

    double progress = 1.0;
    if (timerState.initialSeconds > 0) {
      progress = timerState.remainingSeconds / timerState.initialSeconds;
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive timer size based on available space
            final timerSize = (constraints.maxWidth * 0.65).clamp(180.0, 280.0);
            final timerFontSize = (timerSize * 0.22).clamp(36.0, 64.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      // Header
                      const Text(
                        'Focus Session',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D72D9),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Project Pill Selector — tappable dropdown
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
                                      const Icon(Icons.flag_rounded, size: 16, color: Color(0xFF59A98C)),
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
                                color: const Color(0xFFE0F2F1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFB2DFDB), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF26A69A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      taskLabel,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF455A64),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF455A64),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Timer Display — responsive size
                      SizedBox(
                        width: timerSize,
                        height: timerSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: timerSize,
                              height: timerSize,
                              child: ProgressRing(progress: progress),
                            ),
                            Text(
                              _formatTime(timerState.remainingSeconds),
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: timerFontSize,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: -2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time Scroller / Spacer
                      if (!timerState.isRunning && timerState.mode == TimerMode.focus && timerState.remainingSeconds == timerState.initialSeconds) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: const Color(0xFFEF5350),
                                  inactiveTrackColor: const Color(0xFFEF5350).withOpacity(0.2),
                                  thumbColor: const Color(0xFFEF5350),
                                  trackHeight: 6.0,
                                  overlayColor: const Color(0xFFEF5350).withOpacity(0.15),
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 4),
                                  tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 3),
                                  activeTickMarkColor: Colors.white.withOpacity(0.6),
                                  inactiveTickMarkColor: const Color(0xFFEF5350).withOpacity(0.4),
                                ),
                                child: Slider(
                                  value: settings.focusDuration.toDouble(),
                                  min: 1.0,
                                  max: 60.0,
                                  divisions: 59,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    ref.read(settingsProvider.notifier).updateFocusDuration(val.toInt());
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text('1m', style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w800, fontSize: 16)),
                                        Text('60m', style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w800, fontSize: 16)),
                                      ],
                                    ),
                                    const Text('|', style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.w800, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        const SizedBox(height: 20),
                      ],

                      // Timer Controls
                      Builder(
                        builder: (context) {
                          if (timerState.isRunning) {
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                timerNotifier.pause();
                              },
                              child: Container(
                                width: 160,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFCE93D8),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Text(
                                  'Pause',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          } else if (timerState.remainingSeconds < timerState.initialSeconds && timerState.remainingSeconds > 0) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    timerNotifier.start();
                                  },
                                  child: Container(
                                    width: 140,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFCE93D8),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        titlePadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                                        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                                        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                                        title: const Text(
                                          'Stop Focus Time?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        content: const Text(
                                          'Your current session progress will be lost.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () => Navigator.of(ctx).pop(),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(14),
                                                      border: Border.all(
                                                        color: const Color(0xFFCE93D8),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(ctx).pop();
                                                    timerNotifier.reset();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFFFF6B6B), Color(0xFFEF5350)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(14),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(0xFFEF5350).withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Text(
                                                      'Stop',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 140,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFCE93D8),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Text(
                                      'Stop',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (timerState.remainingSeconds == 0) {
                                  timerNotifier.reset();
                                }
                                timerNotifier.start();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDE4EC),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: const Color(0xFFCE93D8),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Color(0xFFEF5350),
                                      size: 28,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Start Focus',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // Achievement Card
                      if (achievements.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium_outlined, color: Color(0xFF26A69A), size: 40),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'No recent achievements yet.\nComplete a focus session to log one!',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF455A64)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F6F0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                              leading: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.stars,
                                    color: Color(0xFF26A69A),
                                    size: 44,
                                  ),
                                  Positioned(
                                    top: 0,
                                    child: Row(
                                      children: [
                                        Container(width: 8, height: 6, color: const Color(0xFF26A69A)),
                                        const SizedBox(width: 4),
                                        Container(width: 8, height: 6, color: const Color(0xFF26A69A)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              title: const Text(
                                'Recent Achievement',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    achievements.first.topic,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    achievements.first.log,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF26A69A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              children: [
                                if (achievements.length > 1) ...[
                                  const Divider(color: Color(0xFFE0E0E0), height: 24),
                                  ...achievements.skip(1).map((achievement) {
                                    String dateStr = '${achievement.timestamp.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][achievement.timestamp.month - 1]}';
                                    int index = achievements.indexOf(achievement);
                                    Color logColor = index >= 2 ? Colors.grey.shade600 : const Color(0xFF26A69A);

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  achievement.topic,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  achievement.log,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: logColor,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      ref.read(navigationIndexProvider.notifier).setIndex(0, scrollToBottom: true);
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'Click for more',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 16, color: Colors.black87),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
