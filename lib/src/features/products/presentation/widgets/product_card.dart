import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/products/domain/models/product.dart';
import 'package:pengespareapp/src/features/achievements/presentation/widgets/achievement_celebration_dialog.dart';
import 'package:pengespareapp/src/features/products/presentation/widgets/pre_purchase_dialog.dart';
import 'package:pengespareapp/src/features/products/presentation/widgets/extended_cooldown_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every second to show countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '0:00:00';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 24) {
      final days = (hours / 24).floor();
      return '$days dager ${hours % 24}t';
    }
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openUrl() async {
    if (widget.product.url == null) return;
    
    final uri = Uri.parse(widget.product.url!);
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke åpne lenken: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConfetti() {
    if (!mounted) return;
    
    // Create an overlay entry to show confetti on top of everything
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    // Create a new controller for this confetti instance
    final confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: -pi / 2, // Up
              blastDirectionality: BlastDirectionality.explosive, // Spread in all directions
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
    );
    
    overlay.insert(overlayEntry);
    confettiController.play();
    
    // Remove overlay and dispose controller after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
      confettiController.dispose();
    });
  }

  void _showDecisionDialog() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.stillWantThis)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.product.price.toStringAsFixed(0)} kr',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nå som du har ventet, hvordan føler du?'),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () async {
              // Close decision dialog first
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              
              // Show extended cooldown dialog
              if (context.mounted) {
                final extendedDays = await showDialog<int?>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => ExtendedCooldownDialog(
                    productName: widget.product.name,
                  ),
                );
                
                if (extendedDays != null && extendedDays > 0) {
                  // User wants to extend cooldown
                  await ref.read(productsProvider.notifier).extendCooldown(widget.product, extendedDays);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('OK! Du får se "${widget.product.name}" igjen om $extendedDays ${extendedDays == 1 ? 'dag' : 'dager'} ⏰'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } else if (extendedDays == -1) {
                  // User chose "Nei, ikke kjøp" - mark as avoided
                  final newAchievements = await ref.read(productsProvider.notifier).markAsAvoided(widget.product);
                  
                  // Show confetti animation!
                  _showConfetti();
                  
                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bra jobbet! Du unngikk ${widget.product.name} 🎉'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    
                    // Show achievement celebration dialog if any achievements were unlocked
                    if (newAchievements.isNotEmpty) {
                      // Wait a moment for confetti to start
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      for (final achievement in newAchievements) {
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (context) => AchievementCelebrationDialog(
                              achievement: achievement,
                            ),
                          );
                        }
                      }
                    }
                  }
                }
              }
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Trenger ikke'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              // Close decision dialog first
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              
              // Show pre-purchase questions dialog
              if (context.mounted) {
                final shouldPurchase = await showDialog<bool>(
                  context: context,
                  builder: (context) => PrePurchaseDialog(
                    productName: widget.product.name,
                  ),
                );
                
                if (shouldPurchase == true) {
                  // User confirmed purchase
                  final newAchievements = await ref.read(productsProvider.notifier).markAsPlannedPurchase(widget.product);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Flott! Du kjøper ${widget.product.name} planlagt 👍'),
                      ),
                    );
                    
                    // Show achievement celebration if any were unlocked
                    if (newAchievements.isNotEmpty) {
                      for (final achievement in newAchievements) {
                        if (context.mounted) {
                          await showDialog(
                            context: context,
                            builder: (context) => AchievementCelebrationDialog(
                              achievement: achievement,
                            ),
                          );
                        }
                      }
                    }
                  }
                }
              }
            },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Vil kjøpe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    
    final isFinished = widget.product.isTimerFinished;
    final progress = widget.product.progress;
    final timeRemaining = widget.product.timeRemaining;
    final workHours = widget.product.calculateWorkHours(settings.hourlyWage);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isFinished ? 4 : 1,
          shadowColor: isFinished ? theme.colorScheme.primary : null,
          child: InkWell(
            onTap: isFinished ? _showDecisionDialog : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: isFinished
                  ? BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Product Image (if available)
              if (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.product.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.product.price.toStringAsFixed(0)} ${settings.currencySymbol}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.product.url != null)
                    IconButton(
                      onPressed: _openUrl,
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'Åpne lenke',
                    ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.delete),
                          content: Text('Slett ${widget.product.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton(
                              onPressed: () {
                                ref.read(productsProvider.notifier).deleteProduct(widget.product.id);
                                Navigator.pop(context);
                              },
                              child: Text(l10n.delete),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Work Hours
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.hoursOfWork(workHours.toStringAsFixed(1)),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),

              const SizedBox(height: 12),

              // Timer Status
              if (isFinished) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.timerFinished,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _showDecisionDialog,
                    child: Text(l10n.stillWantThis),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.timeRemaining,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    Text(
                      _formatDuration(timeRemaining),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                              const SizedBox(width: 12),
                              Text(l10n.iAmWeak),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Er du sikker på at du vil gi etter?'),
                              const SizedBox(height: 8),
                              Text(
                                'Dette vil bli registrert som et impulskjøp og påvirke statistikken din negativt.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(l10n.cancel),
                            ),
                            FilledButton.icon(
                              onPressed: () async {
                                final newAchievements = await ref.read(productsProvider.notifier).markAsImpulseBuy(widget.product);
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${widget.product.name} registrert som impulskjøp'),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                  
                                  // Show achievement celebration if any were unlocked
                                  if (newAchievements.isNotEmpty) {
                                    for (final achievement in newAchievements) {
                                      if (context.mounted) {
                                        await showDialog(
                                          context: context,
                                          builder: (context) => AchievementCelebrationDialog(
                                            achievement: achievement,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Kjøp nå'),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: Text(l10n.iAmWeak),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
