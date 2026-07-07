import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/quote_card.dart';
import '../widgets/empty_state.dart';

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
      curve: Curves.easeOutCubic,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: favorites.favorites.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_outline_rounded,
              title: 'No favorites yet',
              subtitle: 'Tap the heart icon on a quote\nto save it here.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: FadeTransition(
                    opacity: _headerAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(_headerAnim),
                      child: Row(
                        children: [
                          Text(
                            '${favorites.favorites.length} saved',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Swipe to remove',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: colorScheme.error.withValues(alpha: 0.1),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: colorScheme.error,
                              ),
                            ),
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
        curve: Curves.easeOutCubic,
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
