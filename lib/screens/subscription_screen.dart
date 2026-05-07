import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedOption = 1; // 0 for Monthly, 1 for Annual

  @override
  Widget build(BuildContext context) {
    Color annualColor = _selectedOption == 1 ? const Color(0xFFE31B8F) : Colors.black;
    Color monthlyColor = _selectedOption == 0 ? const Color(0xFFE31B8F) : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Subscription Plan',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1565C0),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Illustration Section
            SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/subscription_header.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
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
                      color: Colors.black87,
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
                  
                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3A000), // Orange
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
