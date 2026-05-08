import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'auth_provider.dart';

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

  Map<String, dynamic> toMap() {
    final user = sb.Supabase.instance.client.auth.currentUser;
    return {
      if (user != null) 'user_id': user.id,
      'name': name,
      'current_step': currentStep,
      'notes': notes,
      'target_hours': targetHours,
      'logged_hours': loggedHours,
      'deadline': deadline.toIso8601String(),
      'is_achieved': isAchieved,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      name: map['name'],
      currentStep: map['current_step'] ?? '',
      notes: map['notes'] ?? '',
      targetHours: map['target_hours'] ?? 10,
      loggedHours: (map['logged_hours'] as num?)?.toDouble() ?? 0.0,
      deadline: DateTime.parse(map['deadline']),
      isAchieved: map['is_achieved'] ?? false,
    );
  }

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
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  @override
  List<Goal> build() {
    // Watch auth state — this causes the provider to rebuild on login/logout
    final user = ref.watch(currentUserProvider);
    if (user == null) return []; // Clear data immediately on logout
    _fetchGoals(user.id);
    return [];
  }

  Future<void> _fetchGoals(String userId) async {
    try {
      final data = await _supabase
          .from('goals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      
      state = (data as List).map((g) => Goal.fromMap(g)).toList();
    } catch (e) {
      print('Error fetching goals: $e');
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      final data = await _supabase
          .from('goals')
          .insert(goal.toMap())
          .select()
          .single();
      
      final newGoal = Goal.fromMap(data);
      state = [...state, newGoal];
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<void> removeGoal(String id) async {
    try {
      await _supabase.from('goals').delete().eq('id', id);
      state = state.where((g) => g.id != id).toList();
    } catch (e) {
      print('Error removing goal: $e');
    }
  }

  Future<void> markAchieved(String id) async {
    try {
      await _supabase.from('goals').update({'is_achieved': true}).eq('id', id);
      state = [
        for (final g in state)
          if (g.id == id) g.copyWith(isAchieved: true) else g,
      ];
    } catch (e) {
      print('Error marking goal achieved: $e');
    }
  }

  Future<void> updateGoal(String id, {String? name, String? currentStep, String? notes, int? targetHours, double? loggedHours, DateTime? deadline}) async {
    final updates = {
      if (name != null) 'name': name,
      if (currentStep != null) 'current_step': currentStep,
      if (notes != null) 'notes': notes,
      if (targetHours != null) 'target_hours': targetHours,
      if (loggedHours != null) 'logged_hours': loggedHours,
      if (deadline != null) 'deadline': deadline.toIso8601String(),
    };

    try {
      await _supabase.from('goals').update(updates).eq('id', id);
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
    } catch (e) {
      print('Error updating goal: $e');
    }
  }

  Future<void> logFocusMinutes(String id, int minutes) async {
    final goal = state.firstWhere((g) => g.id == id);
    final newLoggedHours = goal.loggedHours + (minutes / 60.0);
    
    try {
      await _supabase.from('goals').update({'logged_hours': newLoggedHours}).eq('id', id);
      state = [
        for (final g in state)
          if (g.id == id)
            g.copyWith(loggedHours: newLoggedHours)
          else
            g,
      ];
    } catch (e) {
      print('Error logging focus minutes: $e');
    }
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
