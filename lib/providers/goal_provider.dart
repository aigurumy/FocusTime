import 'package:flutter_riverpod/flutter_riverpod.dart';

class Goal {
  final String id;
  final String name;
  final String currentStep;
  final String notes;
  final int targetHours;
  final double loggedHours;
  final DateTime deadline;
  final bool isAchieved;

  Goal({
    required this.id,
    required this.name,
    this.currentStep = '',
    this.notes = '',
    this.targetHours = 10,
    this.loggedHours = 0,
    DateTime? deadline,
    this.isAchieved = false,
  }) : deadline = deadline ?? DateTime.now().add(const Duration(days: 30));

  double get progressPercent =>
      targetHours > 0 ? (loggedHours / targetHours).clamp(0.0, 1.0) : 0.0;

  int get daysLeft => deadline.difference(DateTime.now()).inDays.clamp(0, 9999);

  Goal copyWith({
    String? name,
    String? currentStep,
    String? notes,
    int? targetHours,
    double? loggedHours,
    DateTime? deadline,
    bool? isAchieved,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      currentStep: currentStep ?? this.currentStep,
      notes: notes ?? this.notes,
      targetHours: targetHours ?? this.targetHours,
      loggedHours: loggedHours ?? this.loggedHours,
      deadline: deadline ?? this.deadline,
      isAchieved: isAchieved ?? this.isAchieved,
    );
  }
}

class GoalListNotifier extends Notifier<List<Goal>> {
  @override
  List<Goal> build() {
    return [];
  }

  void addGoal(Goal goal) {
    state = [...state, goal];
  }

  void removeGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }

  void markAchieved(String id) {
    state = [
      for (final g in state)
        if (g.id == id) g.copyWith(isAchieved: true) else g,
    ];
  }

  void updateGoal(String id, {String? name, String? currentStep, String? notes, int? targetHours, double? loggedHours, DateTime? deadline}) {
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(
            name: name,
            currentStep: currentStep,
            notes: notes,
            targetHours: targetHours,
            loggedHours: loggedHours,
            deadline: deadline,
          )
        else
          g,
    ];
  }

  /// Log focus minutes to a specific goal
  void logFocusMinutes(String id, int minutes) {
    final hours = minutes / 60.0;
    state = [
      for (final g in state)
        if (g.id == id)
          g.copyWith(loggedHours: g.loggedHours + hours)
        else
          g,
    ];
  }
}

final goalProvider = NotifierProvider<GoalListNotifier, List<Goal>>(() {
  return GoalListNotifier();
});

/// Convenience provider: only active (not achieved and not expired) goals
final activeGoalsProvider = Provider<List<Goal>>((ref) {
  final now = DateTime.now();
  return ref.watch(goalProvider).where((g) {
    if (g.isAchieved) return false;
    final endOfDeadlineDay = DateTime(g.deadline.year, g.deadline.month, g.deadline.day, 23, 59, 59);
    return now.isBefore(endOfDeadlineDay);
  }).toList();
});

/// Convenience provider: achieved or expired goals (Archived)
final achievedGoalsProvider = Provider<List<Goal>>((ref) {
  final now = DateTime.now();
  return ref.watch(goalProvider).where((g) {
    if (g.isAchieved) return true;
    final endOfDeadlineDay = DateTime(g.deadline.year, g.deadline.month, g.deadline.day, 23, 59, 59);
    return now.isAfter(endOfDeadlineDay);
  }).toList();
});
