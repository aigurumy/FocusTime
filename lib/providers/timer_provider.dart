import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_provider.dart';

enum TimerMode { focus, shortBreak, longBreak }

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

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    ref.listen<SettingsState>(settingsProvider, (previous, next) {
      if (state.isRunning) return;
      
      if (state.mode == TimerMode.focus && next.focusDuration * 60 != state.initialSeconds) {
        state = state.copyWith(
          initialSeconds: next.focusDuration * 60,
          remainingSeconds: next.focusDuration * 60,
        );
      } else if (state.mode == TimerMode.shortBreak && next.breakDuration * 60 != state.initialSeconds) {
        state = state.copyWith(
          initialSeconds: next.breakDuration * 60,
          remainingSeconds: next.breakDuration * 60,
        );
      }
    });

    final settings = ref.read(settingsProvider);

    return TimerState(
      remainingSeconds: settings.focusDuration * 60,
      initialSeconds: settings.focusDuration * 60,
      isRunning: false,
      mode: TimerMode.focus,
    );
  }

  void start() {
    if (state.isRunning || state.remainingSeconds == 0) return;
    
    WakelockPlus.enable();
    state = state.copyWith(isRunning: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        WakelockPlus.disable();
        state = state.copyWith(isRunning: false);
        _showNotification();
      }
    });
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

  void pause() {
    _timer?.cancel();
    WakelockPlus.disable();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    pause();
    state = state.copyWith(remainingSeconds: state.initialSeconds);
  }

  void setMode(TimerMode mode) {
    pause();
    final settings = ref.read(settingsProvider);
    int minutes = settings.focusDuration;
    if (mode == TimerMode.shortBreak) {
      minutes = settings.breakDuration;
    } else if (mode == TimerMode.longBreak) {
      minutes = 15; // Still fixed
    }
    
    state = state.copyWith(
      mode: mode,
      initialSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
    );
  }

  Future<void> _showNotification() async {
    final settings = ref.read(settingsProvider);
    final plugin = ref.read(notificationsPluginProvider);
    
    const androidDetails = AndroidNotificationDetails(
      'focus_timer_channel',
      'Focus Timer Alerts',
      channelDescription: 'Notifications for timer completion',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    
    String title = "Session Complete";
    String body = "Time's up!";
    if (state.mode == TimerMode.focus) {
      title = "Focus Session Complete!";
      body = "Great job on '${settings.currentTask}'! Time for a break.";
    } else {
      title = "Break Complete!";
      body = "Ready to get back to work on '${settings.currentTask}'?";
    }

    await plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

final notificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});
