import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/categories_screen.dart';
import 'theme/app_theme.dart';

class QuoteApp extends StatefulWidget {
  const QuoteApp({super.key});

  @override
  State<QuoteApp> createState() => _QuoteAppState();
}

class _QuoteAppState extends State<QuoteApp> {
  int _currentIndex = 0;
  bool _showSplash = true;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'QuoteHive',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: _showSplash
          ? const SplashScreen(child: SizedBox.shrink())
          : MainScaffold(
              currentIndex: _currentIndex,
              previousIndex: _previousIndex,
              onTabChange: (i) {
                setState(() {
                  _previousIndex = _currentIndex;
                  _currentIndex = i;
                });
              },
            ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final int currentIndex;
  final int previousIndex;
  final ValueChanged<int> onTabChange;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.previousIndex,
    required this.onTabChange,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _navAnimController;
  late Animation<double> _navAnim;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _navAnim = CurvedAnimation(
      parent: _navAnimController,
      curve: AppTheme.premiumCurve,
    );
    _navAnimController.forward();
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const CategoriesScreen(),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 88 + bottomInset),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: AppTheme.premiumCurve,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final isForward =
                    widget.currentIndex > widget.previousIndex;
                final offset = isForward
                    ? const Offset(0.08, 0)
                    : const Offset(-0.08, 0);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: offset,
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: AppTheme.premiumCurve,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(widget.currentIndex),
                child: screens[widget.currentIndex],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 20,
            child: FadeTransition(
              opacity: _navAnim,
              child: _ThemeToggleChip(),
            ),
          ),
          Positioned(
            bottom: 16 + bottomInset,
            left: 20,
            right: 20,
            child: FadeTransition(
              opacity: _navAnim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _navAnimController,
                    curve: AppTheme.premiumCurve,
                  ),
                ),
                child: _FloatingNav(
                  currentIndex: widget.currentIndex,
                  onTap: widget.onTabChange,
                  isDark: isDark,
                  colorScheme: colorScheme,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : colorScheme.surface.withValues(alpha: 0.8),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;
  final ColorScheme colorScheme;

  const _FloatingNav({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final destinations = [
      (icon: Icons.auto_awesome_rounded, label: 'Discover'),
      (icon: Icons.favorite_rounded, label: 'Favorites'),
      (icon: Icons.category_rounded, label: 'Categories'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            color: isDark
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                : colorScheme.surface.withValues(alpha: 0.75),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(destinations.length, (i) {
              final dest = destinations[i];
              final selected = currentIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: AppTheme.premiumCurve,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          dest.icon,
                          size: 22,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.45),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dest.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: selected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
