import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  String _taskName = 'Untitled';

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final dynamic taskData = await FlutterForegroundTask.getData(key: 'taskName');
    if (taskData is String) _taskName = taskData;
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Phase 2: Read absolute end-time instead of decrementing a counter.
    // This is drift-free and survives Doze mode interruptions.
    final dynamic taskData = await FlutterForegroundTask.getData(key: 'taskName');
    if (taskData is String) _taskName = taskData;

    final dynamic endTimeStr = await FlutterForegroundTask.getData(key: 'endTime');

    if (endTimeStr is String) {
      final endTime = DateTime.parse(endTimeStr);
      final remaining = endTime.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        // Timer expired — the AlarmManager notification will handle the alert.
        FlutterForegroundTask.updateService(
          notificationTitle: '✅ Session Complete!',
          notificationText: 'Time is up. Check your notification.',
        );
        // Give the system a moment to show the alarm notification, then stop.
        await Future.delayed(const Duration(seconds: 3));
        FlutterForegroundTask.stopService();
      } else {
        final minutes = (remaining / 60).floor();
        final seconds = remaining % 60;
        final timeString =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        FlutterForegroundTask.updateService(
          notificationTitle: 'Focus Session Active',
          notificationText: 'Task: $_taskName | ⏱ $timeString remaining',
        );

        // Send remaining seconds back to the main UI isolate (if alive).
        FlutterForegroundTask.sendDataToMain(remaining);
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Nothing to clean up — the alarm notification is managed separately.
  }
}
