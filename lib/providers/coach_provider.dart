import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'achievement_provider.dart';
import 'goal_provider.dart';

class CoachAnalysis {
  final double totalHoursToday;
  final double totalHoursThisWeek;
  final String compliment;
  final String advice;
  final String statusEmoji;
  final List<GoalProgressAnalysis> goalAnalyses;

  CoachAnalysis({
    required this.totalHoursToday,
    required this.totalHoursThisWeek,
    required this.compliment,
    required this.advice,
    required this.statusEmoji,
    required this.goalAnalyses,
  });
}

class GoalProgressAnalysis {
  final String goalName;
  final double progress;
  final double requiredDailyHours;
  final bool isAhead;

  GoalProgressAnalysis({
    required this.goalName,
    required this.progress,
    required this.requiredDailyHours,
    required this.isAhead,
  });
}

final coachProvider = Provider<CoachAnalysis>((ref) {
  final achievements = ref.watch(achievementProvider);
  final goals = ref.watch(activeGoalsProvider);
  
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  // 1. Calculate Summaries
  final minsToday = achievements
      .where((a) => a.timestamp.isAfter(todayStart))
      .fold<int>(0, (sum, a) => sum + a.durationMinutes);
  
  final minsThisWeek = achievements
      .where((a) => a.timestamp.isAfter(weekStart))
      .fold<int>(0, (sum, a) => sum + a.durationMinutes);

  final hoursToday = minsToday / 60.0;
  final hoursThisWeek = minsThisWeek / 60.0;

  // 2. Goal Analysis
  List<GoalProgressAnalysis> goalAnalyses = [];
  bool anyGoalBehind = false;
  bool anyGoalAhead = false;

  for (final goal in goals) {
    final daysLeft = goal.deadline.difference(now).inDays;
    final remainingHours = goal.targetHours - goal.loggedHours;
    final requiredDaily = daysLeft > 0 ? (remainingHours / daysLeft) : remainingHours;
    
    // Simple heuristic: if we've logged more than 10% of total target per week, we are "on track"
    // Better heuristic: compare current progress with time elapsed
    final totalDuration = goal.deadline.difference(now.subtract(const Duration(days: 30))).inDays; // Assuming 30 day default
    final elapsedDays = 30 - daysLeft;
    final expectedProgress = elapsedDays / 30.0;
    final isAhead = (goal.loggedHours / goal.targetHours) >= expectedProgress;

    if (isAhead) anyGoalAhead = true;
    else anyGoalBehind = true;

    goalAnalyses.add(GoalProgressAnalysis(
      goalName: goal.name,
      progress: goal.loggedHours / goal.targetHours,
      requiredDailyHours: requiredDaily.clamp(0, 24),
      isAhead: isAhead,
    ));
  }

  // 3. Feedback System (Encouraging Personal Coach Tone)
  String compliment = "Welcome back! Ready to focus today?";
  String advice = "Every small step counts. Try starting with a short 10-minute session to build momentum.";
  String emoji = "👋";

  if (hoursToday > 0) {
    compliment = "Great start today! You've already put in ${hoursToday.toStringAsFixed(1)} hours of focus.";
    emoji = "✨";
    if (hoursToday > 2) {
      compliment = "You're on fire! ${hoursToday.toStringAsFixed(1)} hours of deep work is incredible.";
      emoji = "🔥";
    }
  }

  // Habit-focused advice
  if (goals.isEmpty) {
    advice = "Setting a clear goal is the first step to success. Why not create one today?";
  } else if (anyGoalBehind) {
    advice = "Your goals are waiting for you! Try 'habit stacking'—do a 25-minute focus session right after your morning coffee.";
    emoji = "☕";
  } else if (anyGoalAhead) {
    advice = "You're crushing your schedule! Remember to take short breaks to keep your mental energy high.";
    emoji = "💪";
  } else if (achievements.length > 5) {
    advice = "Consistency is your superpower. Try to keep your focus sessions at the same time every day to make it a reflex.";
    emoji = "🧠";
  }

  return CoachAnalysis(
    totalHoursToday: hoursToday,
    totalHoursThisWeek: hoursThisWeek,
    compliment: compliment,
    advice: advice,
    statusEmoji: emoji,
    goalAnalyses: goalAnalyses,
  );
});
