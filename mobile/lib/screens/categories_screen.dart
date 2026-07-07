import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quote_service.dart';
import '../providers/theme_provider.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categories = _categories ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Choose a mood',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            curve: Curves.easeOutCubic,
                          ),
                        );

                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(anim),
                            child: _CategoryCard(
                              info: cat,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('${cat.name} quotes coming soon'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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

class _CategoryCard extends StatefulWidget {
  final _CategoryInfo info;
  final VoidCallback onTap;

  const _CategoryCard({required this.info, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          widget.info.color.withValues(alpha: 0.2),
                          widget.info.color.withValues(alpha: 0.05),
                        ]
                      : [
                          widget.info.lightColor.withValues(alpha: 0.15),
                          widget.info.lightColor.withValues(alpha: 0.05),
                        ],
                ),
                border: Border.all(
                  color: (isDark
                          ? widget.info.color
                          : widget.info.lightColor)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.info.icon,
                    size: 32,
                    color: isDark
                        ? widget.info.lightColor
                        : widget.info.color,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.info.name[0].toUpperCase() +
                        widget.info.name.substring(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
