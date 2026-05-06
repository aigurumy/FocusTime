import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedOption = 1; // 0 for Monthly, 1 for Annual (Popular)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF37474F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Subcription Plan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2879D9),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Let FOCUS\nto Achieve\nmy Goals',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFF06292),
                  height: 1.1,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 60),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Monthly Option
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedOption == 0 ? const Color(0xFFEF39A3) : const Color(0xFFFFA6DA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedOption == 0 ? const Color(0xFFEF39A3) : const Color(0xFFFFA6DA),
                      width: 1.5,
                    ),
                    boxShadow: _selectedOption == 0 ? [
                      BoxShadow(
                        color: const Color(0xFFEF39A3).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly [RM15.00]',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _selectedOption == 0 ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RM3.75 / week',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedOption == 0 ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Annual Option
              GestureDetector(
                onTap: () => setState(() => _selectedOption = 1),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedOption == 1 ? const Color(0xFFEF39A3) : const Color(0xFFFFA6DA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedOption == 1 ? const Color(0xFFEF39A3) : const Color(0xFFFFA6DA),
                      width: 1.5,
                    ),
                    boxShadow: _selectedOption == 1 ? [
                      BoxShadow(
                        color: const Color(0xFFEF39A3).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ] : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annually [RM118.80]',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedOption == 1 ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM2.47 / week',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedOption == 1 ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.whatshot, color: Colors.orange, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Popular Choice',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedOption == 1 ? Colors.white : Colors.black,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Save RM61.10',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF06292),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Subscribe Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Logic for subscription
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD54F),
                    foregroundColor: const Color(0xFF37474F),
                    elevation: 4,
                    shadowColor: const Color(0xFFFFD54F).withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
