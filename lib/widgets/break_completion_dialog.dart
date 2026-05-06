import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';

class BreakCompletionDialog extends ConsumerStatefulWidget {
  const BreakCompletionDialog({super.key});

  @override
  ConsumerState<BreakCompletionDialog> createState() => _BreakCompletionDialogState();
}

class _BreakCompletionDialogState extends ConsumerState<BreakCompletionDialog> {
  @override
  void initState() {
    super.initState();
    // Play the break completion tone when the dialog appears
    Future.microtask(() {
      ref.read(timerProvider.notifier).playSelectedTone(TimerMode.shortBreak);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 45),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with Gradient Background (Matches Image)
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8CC0B8), Color(0xFF6B9B93)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.format_quote_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 35),
            // Quote Text (Bold and Centered)
            const Text(
              '"In this age of infinite information\ndistraction is ultimate enemy\nSuccess belongs to those\nwho master the art of FOCUS."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.black,
                height: 1.4,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 15),
            // Author Text
            const Text(
              '-  Yohaniz Benz',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 45),
            // Ready to Focus Button (Dark Teal, Pill shaped)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38665F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ready to Focus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
