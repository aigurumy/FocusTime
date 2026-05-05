import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const primaryBlue = Color(0xFF2879D9);
    const textDark = Color(0xFF3B4045);
    const textLight = Color(0xFF8E959E);
    const cardBg = Color(0xFFF4F3EE);
    const cardBorder = Color(0xFFE6E4DC);
    const buttonTeal = Color(0xFF59A98C);

    final activeGoals = ref.watch(activeGoalsProvider);
    final achievedGoals = ref.watch(achievedGoalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Goals',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Goals Header
            Row(
              children: [
                const Icon(
                  Icons.track_changes_outlined,
                  color: primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Active Goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showNewGoalDialog(context, ref),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'New Goal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonTeal,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Active Goal Cards
            if (activeGoals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.flag_outlined, size: 40, color: textLight.withAlpha(180)),
                    const SizedBox(height: 12),
                    const Text(
                      'No active goals yet.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap "+ New Goal" to create one!',
                      style: TextStyle(fontSize: 14, color: textLight),
                    ),
                  ],
                ),
              )
            else
              ...activeGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  goal: goal,
                  primaryBlue: primaryBlue,
                  textDark: textDark,
                  textLight: textLight,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onDismiss: () {
                    ref.read(goalProvider.notifier).removeGoal(goal.id);
                  },
                  onMarkAchieved: () {
                    ref.read(goalProvider.notifier).markAchieved(goal.id);
                  },
                  onEditNotes: () => _showEditNotesDialog(context, ref, goal),
                  onEditGoal: () => _showEditGoalDialog(context, ref, goal),
                ),
              )),

            const SizedBox(height: 32),

            // Achieved Goals Header
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: primaryBlue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Achieved Goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: textLight,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (achievedGoals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorder, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined, size: 40, color: textLight.withAlpha(180)),
                    const SizedBox(height: 12),
                    const Text(
                      'No achieved goals yet.',
                      style: TextStyle(fontSize: 14, color: textLight),
                    ),
                  ],
                ),
              )
            else
              ...achievedGoals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _GoalCard(
                  goal: goal,
                  primaryBlue: primaryBlue,
                  textDark: textDark,
                  textLight: textLight,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  onDismiss: () {
                    ref.read(goalProvider.notifier).removeGoal(goal.id);
                  },
                  onEditNotes: () => _showEditNotesDialog(context, ref, goal),
                  onEditGoal: () => _showEditGoalDialog(context, ref, goal),
                ),
              )),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditNotesDialog(BuildContext context, WidgetRef ref, Goal goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalNotesScreen(goal: goal),
      ),
    );
  }

  void _showNewGoalDialog(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final nameController = TextEditingController();
    final hoursController = TextEditingController(text: '10');
    DateTime selectedDeadline = now;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Row(
                        children: [
                          Icon(Icons.flag_rounded, color: Color(0xFF59A98C), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Create New Goal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3B4045),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Goal Name
                      const Text(
                        'Goal Name',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Build My First App',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF59A98C), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),


                      // Target Hours
                      const Text(
                        'Target Hours',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '10',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                          suffixText: 'hours',
                          suffixStyle: const TextStyle(color: Color(0xFF8E959E)),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF59A98C), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Deadline
                      const Text(
                        'Deadline',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline,
                            firstDate: DateTime(now.year, now.month, now.day),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF59A98C),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xFF3B4045),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDeadline = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF59A98C)),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('MMM dd, yyyy').format(selectedDeadline),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF3B4045),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF8E959E)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: Colors.grey.withAlpha(80)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8E959E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;

                                final targetHours = int.tryParse(hoursController.text.trim()) ?? 10;
                                final goal = Goal(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: name,
                                  notes: '',
                                  targetHours: targetHours,
                                  deadline: selectedDeadline,
                                );

                                ref.read(goalProvider.notifier).addGoal(goal);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF59A98C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Create',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, Goal goal) {
    final nameController = TextEditingController(text: goal.name);
    final hoursController = TextEditingController(text: goal.targetHours.toString());
    DateTime selectedDeadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF2879D9), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Edit Goal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3B4045),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Goal Name
                      const Text(
                        'Goal Name',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Build My First App',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2879D9), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Target Hours
                      const Text(
                        'Target Hours',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: hoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '10',
                          hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                          suffixText: 'hours',
                          suffixStyle: const TextStyle(color: Color(0xFF8E959E)),
                          filled: true,
                          fillColor: const Color(0xFFF7F7F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withAlpha(60)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2879D9), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Deadline
                      const Text(
                        'Deadline',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3B4045)),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDeadline,
                            firstDate: DateTime.now().isBefore(selectedDeadline) ? DateTime.now() : selectedDeadline,
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF2879D9),
                                    onPrimary: Colors.white,
                                    onSurface: Color(0xFF3B4045),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedDeadline = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2879D9)),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('MMM dd, yyyy').format(selectedDeadline),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF3B4045),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF8E959E)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: Colors.grey.withAlpha(80)),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8E959E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameController.text.trim();
                                if (name.isEmpty) return;

                                final targetHours = int.tryParse(hoursController.text.trim()) ?? goal.targetHours;
                                
                                ref.read(goalProvider.notifier).updateGoal(
                                  goal.id,
                                  name: name,
                                  targetHours: targetHours,
                                  deadline: selectedDeadline,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2879D9),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final Color primaryBlue;
  final Color textDark;
  final Color textLight;
  final Color cardBg;
  final Color cardBorder;
  final VoidCallback? onDismiss;
  final VoidCallback? onMarkAchieved;
  final VoidCallback? onEditNotes;
  final VoidCallback? onEditGoal;

  const _GoalCard({
    required this.goal,
    required this.primaryBlue,
    required this.textDark,
    required this.textLight,
    required this.cardBg,
    required this.cardBorder,
    this.onDismiss,
    this.onMarkAchieved,
    this.onEditNotes,
    this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal.progressPercent;
    final percentLabel = '${(percent * 100).round()}%';
    final loggedStr = goal.loggedHours < 1
        ? '${(goal.loggedHours * 60).round()}m'
        : '${goal.loggedHours.toStringAsFixed(1)}h';
    final targetStr = '${goal.targetHours}h';
    final daysLabel = goal.isAchieved
        ? 'Done'
        : '${goal.daysLeft}d left';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Progress
              SizedBox(
                height: 40,
                width: 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 4,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                    Center(
                      child: Text(
                        percentLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: textDark.withAlpha(200),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Title and Notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    if (goal.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          goal.notes,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: textDark.withAlpha(160),
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ] else if (goal.currentStep.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.currentStep,
                        style: TextStyle(
                          fontSize: 14,
                          color: textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Note Icon & Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEditGoal != null || onDismiss != null)
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E8E6),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF757575), size: 20),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'edit') onEditGoal?.call();
                          if (value == 'achieved') onMarkAchieved?.call();
                          if (value == 'delete') onDismiss?.call();
                        },
                        itemBuilder: (_) => [
                          if (onEditGoal != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2879D9)),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                          if (!goal.isAchieved && onMarkAchieved != null)
                            const PopupMenuItem(
                              value: 'achieved',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF59A98C)),
                                  SizedBox(width: 8),
                                  Text('Mark Achieved'),
                                ],
                              ),
                            ),
                          if (onDismiss != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Bottom Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bottom Left: Note Button
              GestureDetector(
                onTap: onEditNotes,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF5A8DEE), width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF5A8DEE),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Note',
                      style: TextStyle(
                        color: Color(0xFF5A8DEE),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Right: Timer & Calendar
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF2879D9), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$loggedStr/$targetStr',
                        style: TextStyle(
                          color: goal.isAchieved
                              ? textLight.withAlpha(200)
                              : const Color(0xFF2879D9).withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: Color(0xFF2879D9), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        daysLabel,
                        style: TextStyle(
                          color: goal.isAchieved
                              ? textLight.withAlpha(200)
                              : const Color(0xFF2879D9).withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalNotesScreen extends ConsumerStatefulWidget {
  final Goal goal;
  const GoalNotesScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalNotesScreen> createState() => _GoalNotesScreenState();
}

class _GoalNotesScreenState extends ConsumerState<GoalNotesScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.goal.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF2879D9);
    const textDark = Color(0xFF3B4045);
    const bgColor = Color(0xFFF0F0F0);
    const containerBg = Color(0xFFF2EFE9);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
          onPressed: () {
            // Auto-save on back
            ref.read(goalProvider.notifier).updateGoal(
                  widget.goal.id,
                  notes: _notesController.text.trim(),
                );
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          widget.goal.name,
          style: const TextStyle(
            color: primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withAlpha(10), width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.notes_rounded, color: textDark.withAlpha(180), size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 25, // Large field as in picture
                  minLines: 20,
                  style: const TextStyle(
                    fontSize: 16,
                    color: textDark,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
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
