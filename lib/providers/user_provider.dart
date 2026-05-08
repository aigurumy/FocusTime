import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProfile {
  final String name;
  final String email;
  final String goalResolution;
  final String profileImageUrl;

  UserProfile({
    required this.name,
    required this.email,
    required this.goalResolution,
    required this.profileImageUrl,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? goalResolution,
    String? profileImageUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      goalResolution: goalResolution ?? this.goalResolution,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return UserProfile(
        name: "Guest User",
        email: "not logged in",
        goalResolution: "Please login to save your goals.",
        profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&h=300&auto=format&fit=crop',
      );
    }

    // Initialize with local state or metadata
    final name = user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? "User";
    final avatar = user.userMetadata?['avatar_url'] ?? "";

    // We'll trigger a fetch from the 'profiles' table in the background
    _fetchProfile(user.id);

    return UserProfile(
      name: name,
      email: user.email ?? "",
      goalResolution: "Focus on your goals today!",
      profileImageUrl: avatar,
    );
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await ref.read(supabaseClientProvider)
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      state = state.copyWith(
        name: data['full_name'],
        goalResolution: data['goal_resolution'],
        profileImageUrl: data['avatar_url'],
      );
    } catch (e) {
      // Profile might not exist yet, we'll create it on first update
      print('Error fetching profile: $e');
    }
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(supabaseClientProvider).from('profiles').upsert({
        'id': user.id,
        'full_name': profile.name,
        'goal_resolution': profile.goalResolution,
        'avatar_url': profile.profileImageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  Future<void> updateName(String name) async {
    final newState = state.copyWith(name: name);
    state = newState;
    await _saveProfile(newState);
  }

  Future<void> updateGoalResolution(String resolution) async {
    final newState = state.copyWith(goalResolution: resolution);
    state = newState;
    await _saveProfile(newState);
  }
  
  Future<void> updateEmail(String email) async {
    state = state.copyWith(email: email);
  }

  Future<void> updateProfileImage(XFile imageFile) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      // Determine extension — web files sometimes have no extension in the name
      String fileExtension = imageFile.name.contains('.')
          ? imageFile.name.split('.').last
          : 'jpg';
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final storagePath = 'avatars/$fileName';

      final imageBytes = await imageFile.readAsBytes();

      await ref.read(supabaseClientProvider).storage.from('avatars').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: FileOptions(contentType: 'image/$fileExtension'),
      );

      final publicUrl = ref
          .read(supabaseClientProvider)
          .storage
          .from('avatars')
          .getPublicUrl(storagePath);

      if (publicUrl.isNotEmpty) {
        final newState = state.copyWith(profileImageUrl: publicUrl);
        state = newState;
        await _saveProfile(newState);
      }
    } catch (e) {
      print('Storage upload failed: $e');
      // If upload fails (e.g. bucket not set up), still show blob URL locally
      // but it won't persist across sessions
      state = state.copyWith(profileImageUrl: imageFile.path);
    }
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(() {
  return UserProfileNotifier();
});
