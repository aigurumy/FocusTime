import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for auth state changes to redirect to Focus page on login
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((data) {
        if (data.session != null && (previous == null || previous.value?.session == null)) {
          // User just logged in, reset navigation to Focus page (index 2)
          ref.read(navigationIndexProvider.notifier).setIndex(2);
        }
      });
    });

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (data) {
        if (data.session != null) {
          return const MainScreen();
        } else {
          return const AuthScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF146E)),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
