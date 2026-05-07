import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedOption = 1; // 0 for Monthly, 1 for Annual

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      ref.read(userProfileProvider.notifier).updateProfileImage(image.path);
    }
  }

  void _showEditProfileDialog(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final goalController = TextEditingController(text: profile.goalResolution);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Goal's Resolution",
                hintText: 'Enter your goal for this year',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(userProfileProvider.notifier).updateName(nameController.text);
              ref.read(userProfileProvider.notifier).updateGoalResolution(goalController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A68FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('blob:') || path.startsWith('data:')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    Color annualColor = _selectedOption == 1 ? const Color(0xFFE31B8F) : Colors.black;
    Color monthlyColor = _selectedOption == 0 ? const Color(0xFFE31B8F) : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xFF070D24),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showEditProfileDialog(userProfile),
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Color(0xFF070D24),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Profile Picture with Camera Icon
                Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: _getImageProvider(userProfile.profileImageUrl),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: () => _pickImage(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF070D24),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF070D24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF78909C),
                  ),
                ),
                const SizedBox(height: 40),
                // Quote Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '“ ${userProfile.goalResolution} “',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF070D24),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Subscription Selection Component
                Text(
                  'Achieve your goals today',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subscribe to Unlock Your Full Potential',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Annual Card
                GestureDetector(
                  onTap: () => setState(() => _selectedOption = 1),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: annualColor, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _selectedOption == 1 ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: annualColor,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Annual',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: annualColor,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'RM 118.90',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: annualColor,
                                  ),
                                ),
                                Text(
                                  '( RM 9.90/month )',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: annualColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE31B8F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Best Value',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Monthly Card
                GestureDetector(
                  onTap: () => setState(() => _selectedOption = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: monthlyColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedOption == 0 ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: monthlyColor,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Monthly',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: monthlyColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'RM 15.00',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: monthlyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bottom Text
                Text(
                  'Recurring billing, cancel anytime',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Subscribe Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logic for subscription
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1A900), // Specified Orange
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Subscribe',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
