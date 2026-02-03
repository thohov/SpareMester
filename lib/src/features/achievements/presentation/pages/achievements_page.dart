import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/src/features/achievements/data/achievement.dart';
import 'package:pengespareapp/src/features/achievements/data/achievement_type.dart';
import 'package:pengespareapp/src/features/achievements/services/achievement_service.dart';

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage> {
  final _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    await _achievementService.initialize();
    final achievements = _achievementService.getAllAchievements();
    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prestasjoner'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 100),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                final isUnlocked = achievement.unlockedAt != null;
                final achievementType = AchievementType.values.firstWhere(
                  (type) => type.id == achievement.id,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isUnlocked ? 2 : 0.5,
                  color: isUnlocked
                      ? null
                      : theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(achievementType.iconName),
                        size: 32,
                        color: isUnlocked
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.4),
                      ),
                    ),
                    title: Text(
                      achievementType.titleKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isUnlocked
                            ? null
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight:
                            isUnlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          achievementType.descriptionKey,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUnlocked
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        if (isUnlocked) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Låst opp ${_formatDate(achievement.unlockedAt!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ikke låst opp ennå',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'i dag';
    } else if (difference.inDays == 1) {
      return 'i går';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dager siden';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'uke' : 'uker'} siden';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
