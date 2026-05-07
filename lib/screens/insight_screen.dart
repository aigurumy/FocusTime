import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart';
import '../providers/achievement_provider.dart';

class InsightScreen extends ConsumerStatefulWidget {
  const InsightScreen({super.key});

  @override
  ConsumerState<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends ConsumerState<InsightScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedPeriod = 'Week';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
        );
        // Clear the flag after scrolling
        ref.read(navigationIndexProvider.notifier).clearScrollFlag();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for scroll flag
    ref.listen<NavigationState>(navigationIndexProvider, (previous, next) {
      if (next.index == 0 && next.scrollToBottom) {
        _scrollToBottom();
      }
    });

    // Check on initial build if we should scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = ref.read(navigationIndexProvider);
      if (navState.index == 0 && navState.scrollToBottom) {
        _scrollToBottom();
      }
    });

    const primaryBlue = Color(0xFF070D24);
    const textDark = Color(0xFF070D24);
    const textLight = Color(0xFF5C6269);
    const teal = Color(0xFF26A69A);
    const cardBg = Color(0xFFF4F3EE);
    const cardBorder = Color(0xFFE6E4DC);

    final achievements = ref.watch(achievementProvider);

    // Compute stats from achievements
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeek = achievements.where((a) =>
        a.timestamp.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
    final totalMinutes = thisWeek.fold<int>(0, (sum, a) => sum + a.durationMinutes);
    final totalHours = totalMinutes / 60.0;
    final sessionsCount = thisWeek.length;

    // Build data for the chart based on selected period
    List<_DayData> chartData = [];
    if (_selectedPeriod == 'Day') {
      for (int i = 0; i < 24; i++) {
        final hourAchievements = achievements.where((a) =>
            a.timestamp.year == now.year &&
            a.timestamp.month == now.month &&
            a.timestamp.day == now.day &&
            a.timestamp.hour == i);
        final mins = hourAchievements.fold<int>(0, (sum, a) => sum + a.durationMinutes);
        
        String hourLabel = '';
        if (i % 6 == 0 || i == 23) {
          final ampm = i >= 12 ? 'pm' : 'am';
          final h = i % 12 == 0 ? 12 : i % 12;
          hourLabel = '$h$ampm';
        }
        
        chartData.add(_DayData(
          dayLabel: hourLabel,
          dateLabel: '',
          minutes: mins,
        ));
      }
    } else {
      final int daysCount = _selectedPeriod == 'Week' ? 7 : 30;
      chartData = List.generate(daysCount, (i) {
        final day = now.subtract(Duration(days: (daysCount - 1) - i));
        final dayAchievements = achievements.where((a) =>
            a.timestamp.year == day.year &&
            a.timestamp.month == day.month &&
            a.timestamp.day == day.day);
        final mins = dayAchievements.fold<int>(0, (sum, a) => sum + a.durationMinutes);
        return _DayData(
          dayLabel: daysCount <= 7 ? _weekdayShort(day.weekday) : (i % 5 == 0 ? '${day.day}' : ''),
          dateLabel: daysCount <= 7 ? '${day.day}' : '',
          minutes: mins,
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Center(
                child: Text(
                  'Insights',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Weekly Insights Header
              const Text(
                'Weekly Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 20),

              // Daily Focus Trend Chart
              _FocusChart(data: chartData, selectedPeriod: _selectedPeriod),
              const SizedBox(height: 16),

              // Period Selection Tabs
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Day', 'Week', 'Month'].map((period) {
                      final isSelected = _selectedPeriod == period;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected 
                              ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                          ),
                          child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF070D24) : const Color(0xFF5C6269),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Total Focus Time Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: teal, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Focus Time',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: totalHours.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const TextSpan(
                            text: '  hours',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.trending_up, size: 14, color: teal),
                          const SizedBox(width: 4),
                          Text(
                            '+12% from last week',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Sessions Completed Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: teal, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'Sessions Completed',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$sessionsCount',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sessionsCount > 0
                          ? 'You\'ve hit your daily goal ${(sessionsCount / 3).ceil()} times this week.'
                          : 'Start a focus session to begin tracking.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Recent Milestones Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium, color: teal, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Milestones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (achievements.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 40, color: textLight.withAlpha(150)),
                            const SizedBox(height: 12),
                            const Text(
                              'No milestones yet.',
                              style: TextStyle(fontSize: 14, color: textLight),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Complete focus sessions to see them here!',
                              style: TextStyle(fontSize: 13, color: textLight),
                            ),
                          ],
                        ),
                      )
                    else
                      ...achievements.take(5).map((a) => _MilestoneItem(achievement: a)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _weekdayShort(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[(weekday - 1) % 7];
  }
}

// ─── Data model for chart ─────────────────────────────────────
class _DayData {
  final String dayLabel;
  final String dateLabel;
  final int minutes;
  const _DayData({required this.dayLabel, required this.dateLabel, required this.minutes});
}

// ─── Daily Focus Trend Chart (custom painted) ─────────────────
class _FocusChart extends StatelessWidget {
  final List<_DayData> data;
  final String selectedPeriod;
  const _FocusChart({required this.data, required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FAFC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Focus Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF070D24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedPeriod == 'Day' ? 'Minutes focused today' : (selectedPeriod == 'Month' ? 'Minutes focused over the last 30 days' : 'Minutes focused over the last 7 days'),
            style: TextStyle(
              fontSize: 12,
              color: Color(0x99070D24),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y-axis labels
              SizedBox(
                width: 32,
                height: 120,
                child: Builder(builder: (context) {
                  final maxMins = data.isEmpty ? 0 : data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
                  final effMax = maxMins > 0 ? maxMins.toDouble() : 60.0;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(4, (i) {
                      final val = effMax * (3 - i) / 3;
                      String lbl;
                      if (val == 0) {
                        lbl = '0';
                      } else if (val >= 60) {
                        final h = val / 60;
                        lbl = '${h.toStringAsFixed(h.truncateToDouble() == h ? 0 : 1)}h';
                      } else {
                        lbl = '${val.toInt()}m';
                      }
                      return Text(
                        lbl,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0x99070D24),
                        ),
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(width: 4),
              // Chart and Day Labels
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: CustomPaint(
                        size: const Size(double.infinity, 120),
                        painter: _ChartPainter(data: data),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Day labels
                    Row(
                      mainAxisAlignment: data.length > 1 ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                      children: data.map((d) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (d.dayLabel.isNotEmpty)
                            Text(
                              d.dayLabel,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xCC070D24),
                              ),
                            ),
                          if (d.dateLabel.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              d.dateLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0x80070D24),
                              ),
                            ),
                          ],
                        ],
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<_DayData> data;
  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxMinutes = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxMinutes > 0 ? maxMinutes.toDouble() : 60.0;

    final points = <Offset>[];
    final segmentWidth = data.length > 1 ? size.width / (data.length - 1) : 0.0;

    for (int i = 0; i < data.length; i++) {
      final x = data.length > 1 ? i * segmentWidth : size.width / 2;
      final y = size.height - (data[i].minutes / effectiveMax * (size.height - 10));
      points.add(Offset(x, y.clamp(5.0, size.height - 5.0)));
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF070D24).withAlpha(15)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Fill area under the line
    if (points.length >= 2) {
      final fillPath = Path()..moveTo(points.first.dx, size.height);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF26A69A).withAlpha(80),
            const Color(0xFF26A69A).withAlpha(10),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF26A69A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    if (points.isNotEmpty) {
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        // Smooth curve
        final prevP = points[i - 1];
        final curP = points[i];
        final midX = (prevP.dx + curP.dx) / 2;
        linePath.cubicTo(midX, prevP.dy, midX, curP.dy, curP.dx, curP.dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = const Color(0xFF26A69A);
    final dotBorder = Paint()
      ..color = const Color(0xFFF3FAFC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}

// ─── Milestone Item (Inside Recent Milestones Card) ────────────
class _MilestoneItem extends StatelessWidget {
  final Achievement achievement;
  const _MilestoneItem({required this.achievement});

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF26A69A);
    const textDark = Color(0xFF3B4045);
    const textLight = Color(0xFF8E959E);

    final day = achievement.timestamp.day.toString();
    final months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    final month = months[achievement.timestamp.month - 1];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Teal circle icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: teal.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flag_rounded, color: teal, size: 16),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.topic,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  achievement.log.isNotEmpty ? achievement.log : 'Focus session',
                  style: const TextStyle(
                    fontSize: 12,
                    color: textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Date and Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$day $month',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              Text(
                '${achievement.durationMinutes}m',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
