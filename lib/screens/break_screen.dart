import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../widgets/progress_ring.dart';

class BreakScreen extends ConsumerStatefulWidget {
  const BreakScreen({super.key});

  @override
  ConsumerState<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends ConsumerState<BreakScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).setMode(TimerMode.shortBreak);
      ref.read(timerProvider.notifier).start();
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    
    double progress = 1.0;
    if (timerState.initialSeconds > 0) {
      progress = timerState.remainingSeconds / timerState.initialSeconds;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F2F1), // Very light teal
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final timerSize = (constraints.maxWidth * 0.7).clamp(200.0, 300.0);
              final timerFontSize = (timerSize * 0.22).clamp(44.0, 72.0);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Break Time',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00796B), // Deep teal
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2DFDB).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Time to refresh your mind',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF004D40),
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    
                    // Timer Display with Glow/Glass effect
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft glow behind the timer
                          Container(
                            width: timerSize * 0.8,
                            height: timerSize * 0.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF26A69A).withOpacity(0.15),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: timerSize,
                            height: timerSize,
                            child: ProgressRing(
                              progress: progress,
                              color: const Color(0xFF26A69A),
                              strokeWidth: 22,
                            ),
                          ),
                          Text(
                            _formatTime(timerState.remainingSeconds),
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: timerFontSize,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF004D40),
                              letterSpacing: -2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              timerNotifier.setMode(TimerMode.focus);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFB2DFDB),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Skip Break',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF00796B),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (timerState.isRunning) {
                                timerNotifier.pause();
                              } else {
                                timerNotifier.start();
                              }
                            },
                            child: Container(
                              height: 60,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF26A69A).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                timerState.isRunning ? 'Pause' : 'Resume',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 64),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
