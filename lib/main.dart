import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:device_preview/device_preview.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/supabase_config.dart';
import 'main_wrapper.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Phase 5: Background handler for the "Stop Alarm" notification action.
// Runs in its own isolate — no provider / widget access allowed here.
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void _stopAlarmBackgroundHandler(fln.NotificationResponse response) {
  if (response.actionId == 'stop_alarm') {
    fln.FlutterLocalNotificationsPlugin().cancel(0);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  if (!kIsWeb) {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  }

  // Request Permissions
  if (!kIsWeb) {
    await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      // Required on Android 12+ for USE_EXACT_ALARM (alarmClock mode)
      Permission.systemAlertWindow,
    ].request();
  }

  // Dark icons for light background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Initialize local notifications
  // ─────────────────────────────────────────────────────────────────────────
  final fln.FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      fln.FlutterLocalNotificationsPlugin();

  const fln.AndroidInitializationSettings initializationSettingsAndroid =
      fln.AndroidInitializationSettings('@mipmap/ic_launcher');
  const fln.DarwinInitializationSettings initializationSettingsIOS =
      fln.DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  final fln.InitializationSettings initializationSettings =
      fln.InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // Phase 5: Handle "Stop Alarm" tap when app is in foreground.
    onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
      if (response.actionId == 'stop_alarm') {
        flutterLocalNotificationsPlugin.cancel(0);
      }
    },
    // Phase 5: Handle "Stop Alarm" tap when app is in background / killed.
    onDidReceiveBackgroundNotificationResponse: _stopAlarmBackgroundHandler,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Phase 1 + 3.2: Alarm-grade notification channel.
  // AudioAttributesUsage.alarm is what makes the sound play through
  // Silent / Vibrate mode, exactly like the stock Android Clock app.
  // ─────────────────────────────────────────────────────────────────────────
  if (!kIsWeb) {
    final fln.AndroidNotificationChannel alarmChannel =
        fln.AndroidNotificationChannel(
      'focus_alarm_channel_v1',
      'Focus Timer Alarm',
      description: 'Alarm-grade alert when your focus session ends.',
      importance: fln.Importance.max,
      playSound: true,
      // Default sound; individual schedules can override per-tone.
      sound: const fln.RawResourceAndroidNotificationSound('victory_1'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
      showBadge: true,
      // ← The critical flag: routes audio through STREAM_ALARM, bypassing
      //   silent/vibrate mode just like the built-in clock app.
      audioAttributesUsage: fln.AudioAttributesUsage.alarm,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            fln.AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);
  }

  // Initialize Foreground Task
  if (!kIsWeb) {
    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'focus_foreground_channel',
        channelName: 'Focus Live Timer',
        channelDescription: 'Shows the active countdown in the notification drawer',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  runApp(
    const ProviderScope(
      child: FocusTimeAppWrapper(),
    ),
  );
}

class FocusTimeAppWrapper extends ConsumerWidget {
  const FocusTimeAppWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDevicePreviewEnabled = ref.watch(settingsProvider.select((s) => s.isDevicePreviewEnabled));
    
    if (kIsWeb) {
      return DevicePreview(
        enabled: !kReleaseMode && isDevicePreviewEnabled,
        builder: (context) => const FocusTimeApp(),
      );
    }

    return WithForegroundTask(
      child: DevicePreview(
        enabled: !kReleaseMode && isDevicePreviewEnabled,
        builder: (context) => const FocusTimeApp(),
      ),
    );
  }
}


class FocusTimeApp extends ConsumerWidget {
  const FocusTimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    return MaterialApp(
      title: 'Focus Time',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF070D24),
          displayColor: const Color(0xFF070D24),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF146E),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF146E),
          surface: const Color(0xFF16161E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainWrapper(),
    );
  }
}
