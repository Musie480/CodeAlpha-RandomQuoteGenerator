import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorites_provider.dart';
import '../widgets/quote_card.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _headerAnim = CurvedAnimation(
      parent: _staggerController,
      curve: AppTheme.premiumCurve,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: favorites.favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline_rounded,
              title: 'No favorites yet',
              subtitle: 'Tap the heart icon on a quote\nto save it here.',
            )
          : SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _headerAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(_headerAnim),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              child: Text(
                                'FAVORITES',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      letterSpacing: 2,
                                    ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${favorites.favorites.length} saved',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Your collection',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.15,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: favorites.favorites.length,
                      itemBuilder: (context, index) {
                        final quote = favorites.favorites[index];
                        return _FadeSlideItem(
                          index: index,
                          controller: _staggerController,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: ValueKey(quote.id),
                              direction: DismissDirection.endToStart,
                              background: _buildDismissBackground(colorScheme),
                              onDismissed: (_) {
                                favorites.removeFavorite(quote.id);
                              },
                              child: QuoteCard(
                                quote: quote,
                                isFavorite: true,
                                onFavoriteToggle: () =>
                                    favorites.removeFavorite(quote.id),
                                onShare: () {
                                  Share.share(
                                      '"${quote.text}" — ${quote.author}');
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: colorScheme.error.withValues(alpha: 0.08),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.15),
        ),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: colorScheme.error,
      ),
    );
  }
}

class _FadeSlideItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _FadeSlideItem({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(
        0.1 + (index * 0.06).clamp(0.0, 0.5),
        0.5 + (index * 0.06).clamp(0.0, 0.5),
        curve: AppTheme.premiumCurve,
      ),
    );

    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}
