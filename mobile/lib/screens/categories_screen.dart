import 'package:flutter/material.dart';
import '../services/quote_service.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  List<_CategoryInfo>? _categories;
  bool _isLoading = true;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _quoteService.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _quoteService.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = _buildCategoryInfos(cats);
        _isLoading = false;
      });
      _staggerController.forward();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categories = _buildCategoryInfos([]);
        _isLoading = false;
      });
      _staggerController.forward();
    }
  }

  List<_CategoryInfo> _buildCategoryInfos(List<String> names) {
    final all = <_CategoryInfo>[
      _CategoryInfo('inspiration', Icons.auto_awesome_rounded,
          const Color(0xFF7C3AED), const Color(0xFFA78BFA)),
      _CategoryInfo('wisdom', Icons.psychology_rounded,
          const Color(0xFF2563EB), const Color(0xFF60A5FA)),
      _CategoryInfo('success', Icons.trending_up_rounded,
          const Color(0xFF059669), const Color(0xFF34D399)),
      _CategoryInfo('life', Icons.spa_rounded,
          const Color(0xFFD97706), const Color(0xFFFBBF24)),
      _CategoryInfo('love', Icons.favorite_rounded,
          const Color(0xFFDC2626), const Color(0xFFF87171)),
      _CategoryInfo('friendship', Icons.people_rounded,
          const Color(0xFF0891B2), const Color(0xFF22D3EE)),
      _CategoryInfo('creativity', Icons.palette_rounded,
          const Color(0xFFDB2777), const Color(0xFFF472B6)),
      _CategoryInfo('humor', Icons.emoji_emotions_rounded,
          const Color(0xFFEA580C), const Color(0xFFFB923C)),
    ];

    if (names.isEmpty) return all;

    return all.where((c) => names.contains(c.name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = _categories ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'MOODS',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                letterSpacing: 2,
                              ),
                        ),
                      ),
                    ),
                    Text(
                      'Choose a\nmood',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Discover quotes by category',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridColumns(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: _aspectRatio(context),
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final anim = CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              0.1 + (index * 0.07).clamp(0.0, 0.5),
                              0.5 + (index * 0.07).clamp(0.0, 0.5),
                              curve: AppTheme.premiumCurve,
                            ),
                          );

                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.12),
                                end: Offset.zero,
                              ).animate(anim),
                              child: _PremiumCategoryCard(
                                info: cat,
                                isDark: isDark,
                                colorScheme: colorScheme,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${cat.name} quotes coming soon'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  int _gridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  double _aspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 1.2;
    return 1.1;
  }
}

class _CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final Color lightColor;

  const _CategoryInfo(this.name, this.icon, this.color, this.lightColor);
}

class _PremiumCategoryCard extends StatefulWidget {
  final _CategoryInfo info;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _PremiumCategoryCard({
    required this.info,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  State<_PremiumCategoryCard> createState() => _PremiumCategoryCardState();
}

class _PremiumCategoryCardState extends State<_PremiumCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
          parent: _pressController, curve: AppTheme.premiumCurve),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catColor = widget.isDark
        ? widget.info.color.withValues(alpha: 0.25)
        : widget.info.lightColor.withValues(alpha: 0.15);
    final borderColor = (widget.isDark
            ? widget.info.color
            : widget.info.lightColor)
        .withValues(alpha: widget.isDark ? 0.2 : 0.15);

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnim.value,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    catColor,
                    catColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: widget.isDark
                      ? widget.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.info.icon,
                      size: 28,
                      color: widget.isDark
                          ? widget.info.lightColor
                          : widget.info.color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.info.name[0].toUpperCase() +
                          widget.info.name.substring(1),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: widget.colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
