import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onShare;

  const QuoteCard({
    super.key,
    required this.quote,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: AppTheme.doubleBezel(
        colorScheme: colorScheme,
        isDark: isDark,
        outerRadius: 28,
        outerBorderColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        outerGradient: isDark
            ? [Colors.white.withValues(alpha: 0.04), Colors.white.withValues(alpha: 0.01)]
            : [Colors.black.withValues(alpha: 0.02), Colors.black.withValues(alpha: 0.005)],
        outerShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        decoration: AppTheme.doubleBezelInner(
          colorScheme: colorScheme,
          isDark: isDark,
          radius: 25,
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    quote.text,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.3),
                        colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      quote.author.isNotEmpty
                          ? quote.author[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quote.author,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
            if (onFavoriteToggle != null || onShare != null) ...[
              const SizedBox(height: 20),
              Container(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onShare != null)
                    _PremiumActionButton(
                      icon: Icons.ios_share_rounded,
                      onPressed: onShare!,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  const SizedBox(width: 4),
                  if (onFavoriteToggle != null)
                    _PremiumActionButton(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      onPressed: onFavoriteToggle!,
                      color: isFavorite
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _PremiumActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.premiumCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.02),
                ),
                child: Icon(widget.icon, size: 20, color: widget.color),
              ),
            ),
          );
        },
      ),
    );
  }
}
