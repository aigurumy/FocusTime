import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

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
    // Watch the current user from Supabase
    final user = ref.watch(currentUserProvider);
    
    // Default values if no user is logged in
    if (user == null) {
      return UserProfile(
        name: "Guest User",
        email: "not logged in",
        goalResolution: "Please login to save your goals.",
        profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&h=300&auto=format&fit=crop',
      );
    }

    // Populate from Supabase user data
    final name = user.userMetadata?['full_name'] ?? user.email?.split('@').first ?? "User";
    final avatar = user.userMetadata?['avatar_url'] ?? 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&h=300&auto=format&fit=crop';

    return UserProfile(
      name: name,
      email: user.email ?? "",
      goalResolution: "Focus on your goals today!",
      profileImageUrl: avatar,
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateGoalResolution(String resolution) {
    state = state.copyWith(goalResolution: resolution);
  }
  
  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateProfileImage(String url) {
    state = state.copyWith(profileImageUrl: url);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(() {
  return UserProfileNotifier();
});
