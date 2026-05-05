import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final int focusDuration; // in minutes
  final int breakDuration; // in minutes
  final String currentTask;
  final bool rainSoundEnabled;
  final bool deepWorkShieldEnabled;
  final bool isDevicePreviewEnabled;
  final String focusTimeTone;
  final String breakTimeTone;

  SettingsState({
    this.focusDuration = 45,
    this.breakDuration = 5,
    this.currentTask = '', // Empty by default
    this.rainSoundEnabled = true,
    this.deepWorkShieldEnabled = true,
    this.isDevicePreviewEnabled = true,
    this.focusTimeTone = 'Victory 5',
    this.breakTimeTone = 'Victory 2',
  });

  SettingsState copyWith({
    int? focusDuration,
    int? breakDuration,
    String? currentTask,
    bool? rainSoundEnabled,
    bool? deepWorkShieldEnabled,
    bool? isDevicePreviewEnabled,
    String? focusTimeTone,
    String? breakTimeTone,
  }) {
    return SettingsState(
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      currentTask: currentTask ?? this.currentTask,
      rainSoundEnabled: rainSoundEnabled ?? this.rainSoundEnabled,
      deepWorkShieldEnabled: deepWorkShieldEnabled ?? this.deepWorkShieldEnabled,
      isDevicePreviewEnabled: isDevicePreviewEnabled ?? this.isDevicePreviewEnabled,
      focusTimeTone: focusTimeTone ?? this.focusTimeTone,
      breakTimeTone: breakTimeTone ?? this.breakTimeTone,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return SettingsState();
  }

  void updateFocusDuration(int minutes) {
    state = state.copyWith(focusDuration: minutes);
  }

  void updateBreakDuration(int minutes) {
    state = state.copyWith(breakDuration: minutes);
  }

  void updateCurrentTask(String taskName) {
    state = state.copyWith(currentTask: taskName);
  }

  void toggleRainSound(bool enabled) {
    state = state.copyWith(rainSoundEnabled: enabled);
  }

  void toggleDeepWorkShield(bool enabled) {
    state = state.copyWith(deepWorkShieldEnabled: enabled);
  }

  void toggleDevicePreview(bool enabled) {
    state = state.copyWith(isDevicePreviewEnabled: enabled);
  }

  void updateFocusTimeTone(String tone) {
    state = state.copyWith(focusTimeTone: tone);
  }

  void updateBreakTimeTone(String tone) {
    state = state.copyWith(breakTimeTone: tone);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(() {
  return SettingsNotifier();
});
