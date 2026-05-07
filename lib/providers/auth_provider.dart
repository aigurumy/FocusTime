import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? ref.watch(supabaseClientProvider).auth.currentUser;
});

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false; // false = not loading

  Future<void> signUpWithEmail(String email, String password) async {
    state = true;
    try {
      await ref.read(supabaseClientProvider).auth.signUp(
        email: email,
        password: password,
      );
    } finally {
      state = false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = true;
    try {
      await ref.read(supabaseClientProvider).auth.signInWithPassword(
        email: email,
        password: password,
      );
    } finally {
      state = false;
    }
  }

  Future<void> signInWithGoogle() async {
    state = true;
    try {
      await ref.read(supabaseClientProvider).auth.signInWithOAuth(
        OAuthProvider.google,
        // For web, this usually just works. For mobile, additional config is needed.
        redirectTo: 'io.supabase.focustime://login-callback/',
      );
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }
}

final authLoadingProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
