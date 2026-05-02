import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return UserProfile(
      name: "User's Name",
      email: "user@email.com",
      goalResolution: "My goal this year is to make million and have healthy and fit body",
      profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=300&h=300&auto=format&fit=crop',
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
