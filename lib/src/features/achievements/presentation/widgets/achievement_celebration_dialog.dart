import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:pengespareapp/src/features/achievements/data/achievement.dart';
import 'package:pengespareapp/src/features/achievements/data/achievement_type.dart';

class AchievementCelebrationDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementCelebrationDialog({
    super.key,
    required this.achievement,
  });

  @override
  State<AchievementCelebrationDialog> createState() =>
      _AchievementCelebrationDialogState();
}

class _AchievementCelebrationDialogState
    extends State<AchievementCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Start confetti immediately when dialog opens
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'star':
        return Icons.star;
      case 'stars':
        return Icons.stars;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'military_tech':
        return Icons.military_tech;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'savings':
        return Icons.savings;
      case 'account_balance':
        return Icons.account_balance;
      case 'shield':
        return Icons.shield;
      case 'verified':
        return Icons.verified;
      case 'trending_up':
        return Icons.trending_up;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'bolt':
        return Icons.bolt;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'payments':
        return Icons.payments;
      case 'attach_money':
        return Icons.attach_money;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'psychology':
        return Icons.psychology;
      case 'event_available':
        return Icons.event_available;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'diamond':
        return Icons.diamond;
      case 'flash_on':
        return Icons.flash_on;
      case 'schedule':
        return Icons.schedule;
      case 'category':
        return Icons.category;
      case 'wb_twilight':
        return Icons.wb_twilight;
      case 'nightlight':
        return Icons.nightlight;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final achievementType = AchievementType.values.firstWhere(
      (type) => type.id == widget.achievement.id,
    );

    return Stack(
      children: [
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconData(achievementType.iconName),
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  '🎉 Prestasjon opplåst! 🎉',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Achievement name
                Text(
                  achievementType.titleKey,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  achievementType.descriptionKey,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Close button
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Flott!'),
                ),
              ],
            ),
          ),
        ),
        // Confetti overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.01,
                numberOfParticles: 200,
                maxBlastForce: 55,
                minBlastForce: 35,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
