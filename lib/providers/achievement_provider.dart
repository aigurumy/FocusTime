import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'auth_provider.dart';

class Achievement {
  final String? id; // Supabase UUID
  final String topic;
  final String log;
  final int durationMinutes;
  final DateTime timestamp;

  Achievement({
    this.id,
    required this.topic,
    required this.log,
    required this.durationMinutes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final user = sb.Supabase.instance.client.auth.currentUser;
    return {
      if (user != null) 'user_id': user.id,
      'topic': topic,
      'log': log,
      'duration_minutes': durationMinutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      topic: map['topic'] ?? 'Untitled',
      log: map['log'] ?? '',
      durationMinutes: map['duration_minutes'] ?? 0,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}

class AchievementNotifier extends Notifier<List<Achievement>> {
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;

  @override
  List<Achievement> build() {
    // Watch auth state — rebuilds and clears data on login/logout
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];
    _fetchAchievements(user.id);
    return [];
  }

  Future<void> _fetchAchievements(String userId) async {
    try {
      final data = await _supabase
          .from('achievements')
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false);
      
      state = (data as List).map((a) => Achievement.fromMap(a)).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
    }
  }

  Future<void> addAchievement(Achievement achievement) async {
    try {
      final data = await _supabase
          .from('achievements')
          .insert(achievement.toMap())
          .select()
          .single();
      
      final newAchievement = Achievement.fromMap(data);
      state = [newAchievement, ...state];
      
      // Keep max 5 items in the local state if needed for UI performance, 
      // but usually we want to see the full log. 
      // For now, let's keep it simple and show all.
    } catch (e) {
      print('Error adding achievement: $e');
    }
  }
}

final achievementProvider = NotifierProvider<AchievementNotifier, List<Achievement>>(() {
  return AchievementNotifier();
});
