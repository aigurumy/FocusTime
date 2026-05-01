import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Achievement {
  final String topic;
  final String log;
  final int durationMinutes;
  final DateTime timestamp;

  Achievement({
    required this.topic,
    required this.log,
    required this.durationMinutes,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'topic': topic,
      'log': log,
      'durationMinutes': durationMinutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      topic: map['topic'] ?? 'Untitled',
      log: map['log'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}

class AchievementNotifier extends Notifier<List<Achievement>> {
  static const String _key = 'achievements_list';
  SharedPreferences? _prefs;

  @override
  List<Achievement> build() {
    _initPrefs();
    return [];
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final String? data = _prefs?.getString(_key);
    if (data != null) {
      final List<dynamic> decodedList = jsonDecode(data);
      final List<Achievement> loadedList = decodedList
          .map((item) => Achievement.fromMap(item as Map<String, dynamic>))
          .toList();
      state = loadedList;
    }
  }

  Future<void> addAchievement(Achievement achievement) async {
    final newList = [achievement, ...state];
    // Keep max 5 items to keep UI clean
    if (newList.length > 5) {
      newList.removeRange(5, newList.length);
    }
    state = newList;
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) return;
    final List<Map<String, dynamic>> mappedList = state.map((e) => e.toMap()).toList();
    await _prefs?.setString(_key, jsonEncode(mappedList));
  }
}

final achievementProvider = NotifierProvider<AchievementNotifier, List<Achievement>>(() {
  return AchievementNotifier();
});
