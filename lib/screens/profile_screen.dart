import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedOption = 1; // 0 for Monthly, 1 for Annual
  XFile? _localImage; // holds local preview before upload completes
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      // Show local preview instantly
      setState(() {
        _localImage = image;
        _isUploadingImage = true;
      });
      // Upload to Supabase Storage in background
      await ref.read(userProfileProvider.notifier).updateProfileImage(image);
      setState(() => _isUploadingImage = false);
    }
  }

  ImageProvider _getLocalImageProvider(XFile file) {
    if (kIsWeb) {
      // On web, XFile.path is a blob URL
      return NetworkImage(file.path);
    }
    return FileImage(File(file.path));
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http') || path.startsWith('blob:') || path.startsWith('data:')) {
      return NetworkImage(path);
    }
    return FileImage(File(path));
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit ${field == 'name' ? 'Name' : 'Quote'}',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF070D24),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter new ${field == 'name' ? 'name' : 'quote'}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: Color(0xFF8DC815), width: 2),
            ),
          ),
          maxLines: field == 'quote' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: const Color(0xFF4B4848),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                if (field == 'name') {
                  ref.read(userProfileProvider.notifier).updateName(controller.text.trim());
                } else {
                  ref.read(userProfileProvider.notifier).updateGoalResolution(controller.text.trim());
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8DC815),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
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
                const Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Color(0xFF070D24),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
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
                        color: Colors.grey.shade100,
                        // Use local preview first, then fall back to Supabase URL
                        image: _localImage != null
                            ? DecorationImage(
                                image: _getLocalImageProvider(_localImage!),
                                fit: BoxFit.cover,
                              )
                            : userProfile.profileImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: _getImageProvider(userProfile.profileImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: (_localImage == null && userProfile.profileImageUrl.isEmpty)
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    // Upload spinner overlay
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _isUploadingImage ? null : () => _pickImage(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isUploadingImage
                                ? Colors.grey
                                : const Color(0xFF070D24),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userProfile.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF070D24),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _showEditDialog('name', userProfile.name),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
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
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Color(0xFF78909C)),
                          onPressed: () => _showEditDialog('quote', userProfile.goalResolution),
                        ),
                      ),
                    ],
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
                    onPressed: userProfile.isPremium 
                      ? null 
                      : () async {
                          await ref.read(userProfileProvider.notifier).updateSubscription(true);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Welcome to FocusTime Premium! 🎉'),
                                backgroundColor: Color(0xFF59A98C),
                              ),
                            );
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: userProfile.isPremium ? Colors.grey : const Color(0xFFF1A900), // Specified Orange
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      userProfile.isPremium ? 'Already Premium' : 'Subscribe',
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
