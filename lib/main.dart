import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_wrapper.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Dark icons for light background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

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
    
    return DevicePreview(
      enabled: !kReleaseMode && isDevicePreviewEnabled,
      builder: (context) => const FocusTimeApp(),
    );
  }
}


class FocusTimeApp extends StatelessWidget {
  const FocusTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Time',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF070D24),
          displayColor: const Color(0xFF070D24),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF146E),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainWrapper(),
    );
  }
}
