import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../services/foreground_service.dart';
import 'settings_provider.dart';

enum TimerMode { focus, shortBreak, longBreak }

// ─────────────────────────────────────────────────────────────────────────────
// Keys used to persist timer state across app restarts / backgrounding
// ─────────────────────────────────────────────────────────────────────────────
const _kEndTime = 'timer_endTime';
const _kInitialSeconds = 'timer_initialSeconds';
const _kTimerMode = 'timer_mode';
const _kTaskName = 'timer_taskName';

class TimerState {
  final int remainingSeconds;
  final int initialSeconds;
  final bool isRunning;
  final TimerMode mode;

  TimerState({
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.isRunning,
    required this.mode,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? initialSeconds,
    bool? isRunning,
    TimerMode? mode,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class TimerNotifier extends Notifier<TimerState> {
  Timer? _displayTimer;   // UI refresh only — not the source of truth
  DateTime? _endTime;     // The real countdown target (source of truth)
  late AudioPlayer _audioPlayer;
  SharedPreferences? _prefs;

  @override
  TimerState build() {
    _audioPlayer = AudioPlayer();
    tz.initializeTimeZones();

    ref.onDispose(() {
      _displayTimer?.cancel();
      _audioPlayer.dispose();
    });

    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (state.isRunning) return;

      if (state.mode == TimerMode.focus &&
          next.focusDuration * 60 != state.initialSeconds) {
        state = state.copyWith(
          initialSeconds: next.focusDuration * 60,
          remainingSeconds: next.focusDuration * 60,
        );
      } else if (state.mode == TimerMode.shortBreak &&
          next.breakDuration * 60 != state.initialSeconds) {
        state = state.copyWith(
          initialSeconds: next.breakDuration * 60,
          remainingSeconds: next.breakDuration * 60,
        );
      }
    });

    final settings = ref.read(settingsProvider);
    final defaultState = TimerState(
      remainingSeconds: settings.focusDuration * 60,
      initialSeconds: settings.focusDuration * 60,
      isRunning: false,
      mode: TimerMode.focus,
    );

    // Phase 4: Restore timer state asynchronously if a session was running.
    _restoreTimerState(defaultState);

    return defaultState;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Phase 4 — Restore a running timer after app cold-start / re-open
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _restoreTimerState(TimerState defaultState) async {
    _prefs ??= await SharedPreferences.getInstance();
    final endTimeStr = _prefs!.getString(_kEndTime);
    if (endTimeStr == null) return;

    final endTime = DateTime.tryParse(endTimeStr);
    if (endTime == null) return;

    final remaining = endTime.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      // Timer already expired while app was away — clean up persisted state.
      await _clearPersistedState();
      return;
    }

    // Timer is still counting down — restore UI state and resume display ticker.
    _endTime = endTime;
    final modeStr = _prefs!.getString(_kTimerMode) ?? 'focus';
    final initialSecs = _prefs!.getInt(_kInitialSeconds) ?? defaultState.initialSeconds;
    final mode = TimerMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => TimerMode.focus,
    );

    state = TimerState(
      remainingSeconds: remaining,
      initialSeconds: initialSecs,
      isRunning: true,
      mode: mode,
    );

    _startDisplayTicker();
    debugPrint('[Timer] Restored: $remaining seconds remaining, mode=$modeStr');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Public API
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> start() async {
    if (state.isRunning || state.remainingSeconds == 0) return;

    // Snapshot remaining seconds BEFORE any await, since state may change.
    final secondsToCount = state.remainingSeconds;
    _endTime = DateTime.now().add(Duration(seconds: secondsToCount));

    WakelockPlus.enable();
    state = state.copyWith(isRunning: true);

    // ── Start the display ticker IMMEDIATELY so the UI counts down. ───────────
    // Background tasks (prefs, alarm, foreground service) run after, in a
    // fire-and-forget block so they cannot block or crash the ticker.
    _startDisplayTicker();

    // ── Background work (non-blocking) ───────────────────────────────────────
    _initBackgroundWork();
  }

  /// Saves state to disk and schedules the alarm — runs after the ticker starts.
  void _initBackgroundWork() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final settings = ref.read(settingsProvider);
      await _prefs!.setString(_kEndTime, _endTime!.toIso8601String());
      await _prefs!.setInt(_kInitialSeconds, state.initialSeconds);
      await _prefs!.setString(_kTimerMode, state.mode.name);
      await _prefs!.setString(_kTaskName, settings.currentTask);
    } catch (e) {
      debugPrint('[Timer] SharedPreferences save failed: $e');
    }

    if (!kIsWeb) {
      try {
        await _scheduleAlarm();
      } catch (e) {
        debugPrint('[Timer] _scheduleAlarm failed: $e');
      }
      try {
        await _startForegroundService();
      } catch (e) {
        debugPrint('[Timer] _startForegroundService failed: $e');
      }
    }
  }

  void pause() {
    _displayTimer?.cancel();
    _endTime = null;
    WakelockPlus.disable();
    if (!kIsWeb) {
      _cancelAlarm();
      _stopForegroundService();
    }
    _clearPersistedState();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    pause();
    state = state.copyWith(remainingSeconds: state.initialSeconds);
  }

  void skip() {
    _displayTimer?.cancel();
    _endTime = null;
    WakelockPlus.disable();
    if (!kIsWeb) {
      _cancelAlarm();
      _stopForegroundService();
    }
    _clearPersistedState();
    state = state.copyWith(remainingSeconds: 0, isRunning: false);
    // Play tone in foreground since user manually skipped.
    playSelectedTone();
  }

  void setMode(TimerMode mode) {
    pause();
    final settings = ref.read(settingsProvider);
    int minutes = settings.focusDuration;
    if (mode == TimerMode.shortBreak) {
      minutes = settings.breakDuration;
    } else if (mode == TimerMode.longBreak) {
      minutes = 15;
    }

    state = state.copyWith(
      mode: mode,
      initialSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
    );
  }

  void startFromTask() {
    pause();
    final settings = ref.read(settingsProvider);
    state = state.copyWith(
      mode: TimerMode.focus,
      initialSeconds: settings.focusDuration * 60,
      remainingSeconds: settings.focusDuration * 60,
    );
    start();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Phase 2 — Display ticker (UI only, not the source of truth)
  // ───────────────────────────────────────────────────────────────────────────
  void _startDisplayTicker() {
    _displayTimer?.cancel();
    _displayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_endTime == null) {
        timer.cancel();
        return;
      }

      final remaining = _endTime!.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        timer.cancel();
        _endTime = null;
        WakelockPlus.disable();
        if (!kIsWeb) _stopForegroundService();
        _clearPersistedState();
        state = state.copyWith(remainingSeconds: 0, isRunning: false);

        // Play alert in foreground — the scheduled notification handles background.
        _onTimerExpiredInForeground();
      } else {
        state = state.copyWith(remainingSeconds: remaining);

        // Keep foreground service data in sync.
        if (!kIsWeb) {
          FlutterForegroundTask.saveData(key: 'endTime', value: _endTime!.toIso8601String());
        }
      }
    });
  }

  /// Called only when the app is in the foreground at the moment of expiry.
  void _onTimerExpiredInForeground() {
    playSelectedTone();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Audio
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> playSelectedTone([TimerMode? forcedMode]) async {
    final settings = ref.read(settingsProvider);
    final currentMode = forcedMode ?? state.mode;
    final tone = currentMode == TimerMode.focus
        ? settings.focusTimeTone
        : settings.breakTimeTone;

    if (tone == 'None') return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$tone.mp3'));
    } catch (e) {
      debugPrint('[Timer] Error playing tone: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Phase 3 — Alarm-grade scheduled notification (fires even in Doze/lock screen)
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _scheduleAlarm() async {
    if (kIsWeb || _endTime == null) return;
    final settings = ref.read(settingsProvider);
    final plugin = ref.read(notificationsPluginProvider);

    final tone = state.mode == TimerMode.focus
        ? settings.focusTimeTone
        : settings.breakTimeTone;

    final resourceName = tone.toLowerCase().replaceAll(' ', '_');
    const String channelId = 'focus_alarm_channel_v1';

    final androidDetails = fln.AndroidNotificationDetails(
      channelId,
      'Focus Timer Alarm',
      channelDescription: 'Alarm-grade alert when your session ends.',
      importance: fln.Importance.max,
      priority: fln.Priority.max,
      fullScreenIntent: true,
      category: fln.AndroidNotificationCategory.alarm,
      ticker: 'Focus session complete!',
      audioAttributesUsage: fln.AudioAttributesUsage.alarm,
      sound: resourceName == 'none'
          ? null
          : fln.RawResourceAndroidNotificationSound(resourceName),
      playSound: resourceName != 'none',
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      visibility: fln.NotificationVisibility.public,
      actions: [
        const fln.AndroidNotificationAction(
          'stop_alarm',
          'Stop Alarm',
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    final darwinDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: resourceName == 'none' ? null : '$resourceName.mp3',
      interruptionLevel: fln.InterruptionLevel.timeSensitive,
    );

    final details = fln.NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = state.mode == TimerMode.focus
        ? '\u2705 Focus Session Complete!'
        : '\u2615 Break Complete!';
    final body = state.mode == TimerMode.focus
        ? "Great job on '${settings.currentTask}'! Time for a break."
        : "Ready to get back to '${settings.currentTask}'?";

    final scheduledTime = tz.TZDateTime.from(_endTime!, tz.local);

    // Try alarmClock mode first (most reliable, used by stock Android Clock).
    // Fall back to exactAllowWhileIdle for ROMs that reject alarmClock
    // without USE_EXACT_ALARM being pre-granted.
    try {
      await plugin.zonedSchedule(
        0, title, body, scheduledTime, details,
        androidScheduleMode: fln.AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            fln.UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('[Timer] Alarm scheduled (alarmClock mode) for $_endTime');
    } catch (e) {
      debugPrint('[Timer] alarmClock mode failed ($e), falling back to exactAllowWhileIdle');
      try {
        await plugin.zonedSchedule(
          0, title, body, scheduledTime, details,
          androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              fln.UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('[Timer] Alarm scheduled (exactAllowWhileIdle fallback) for $_endTime');
      } catch (e2) {
        debugPrint('[Timer] Both alarm modes failed: $e2');
      }
    }
  }

  Future<void> _cancelAlarm() async {
    if (kIsWeb) return;
    final plugin = ref.read(notificationsPluginProvider);
    await plugin.cancel(0);
    debugPrint('[Timer] Alarm cancelled');
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Foreground Service helpers
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _startForegroundService() async {
    if (kIsWeb || _endTime == null) return;
    final settings = ref.read(settingsProvider);

    // Phase 2: pass absolute end-time instead of remaining seconds.
    await FlutterForegroundTask.saveData(
        key: 'endTime', value: _endTime!.toIso8601String());
    await FlutterForegroundTask.saveData(
        key: 'taskName',
        value: settings.currentTask.isEmpty ? 'Untitled' : settings.currentTask);

    if (await FlutterForegroundTask.isRunningService) return;

    await FlutterForegroundTask.startService(
      notificationTitle: 'Focus Session Active',
      notificationText: 'Preparing timer...',
      callback: startCallback,
    );
  }

  Future<void> _stopForegroundService() async {
    if (kIsWeb) return;
    await FlutterForegroundTask.stopService();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Persistence helpers
  // ───────────────────────────────────────────────────────────────────────────
  Future<void> _clearPersistedState() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_kEndTime);
    await _prefs!.remove(_kInitialSeconds);
    await _prefs!.remove(_kTimerMode);
    await _prefs!.remove(_kTaskName);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────
final notificationsPluginProvider =
    Provider<fln.FlutterLocalNotificationsPlugin>((ref) {
  return fln.FlutterLocalNotificationsPlugin();
});

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});
