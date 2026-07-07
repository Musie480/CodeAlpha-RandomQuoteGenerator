import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../providers/favorites_provider.dart';
import '../widgets/quote_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final QuoteService _quoteService = QuoteService();
  Quote? _currentQuote;
  bool _isLoading = true;
  String? _error;
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: AppTheme.premiumCurve,
    );
    _fetchQuote();
  }

  @override
  void dispose() {
    _quoteService.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final quote = await _quoteService.fetchRandomQuote();
      if (!mounted) return;
      setState(() {
        _currentQuote = quote;
        _isLoading = false;
      });
      _entryController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _shareQuote() {
    if (_currentQuote == null) return;
    Share.share('"${_currentQuote!.text}" — ${_currentQuote!.author}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Text(
                  'DISCOVER',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        letterSpacing: 2,
                      ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Quote of\nthe moment',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Daily inspiration tailored for you',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
              ),
              const Spacer(),
              if (_isLoading)
                _buildLoadingState(colorScheme, isDark)
              else if (_error != null)
                _buildErrorState(colorScheme, isDark)
              else if (_currentQuote != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_entryAnim),
                  child: FadeTransition(
                    opacity: _entryAnim,
                    child: QuoteCard(
                      quote: _currentQuote!,
                      isFavorite: context
                          .watch<FavoritesProvider>()
                          .isFavorite(_currentQuote!),
                      onFavoriteToggle: () {
                        context
                            .read<FavoritesProvider>()
                            .toggleFavorite(_currentQuote!);
                      },
                      onShare: _shareQuote,
                    ),
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _NextButton(
                  isLoading: _isLoading || _currentQuote == null,
                  onPressed: _fetchQuote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: AppTheme.doubleBezel(
        colorScheme: colorScheme,
        isDark: isDark,
        outerRadius: 28,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: AppTheme.doubleBezelInner(
          colorScheme: colorScheme,
          isDark: isDark,
          radius: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBlock(
                width: 40, height: 40, colorScheme: colorScheme),
            const SizedBox(height: 20),
            _ShimmerBlock(
                width: double.infinity, height: 18, colorScheme: colorScheme),
            const SizedBox(height: 10),
            _ShimmerBlock(
                width: 0.7, height: 18, colorScheme: colorScheme),
            const SizedBox(height: 26),
            Row(
              children: [
                _ShimmerBlock(
                    width: 32, height: 32, colorScheme: colorScheme,
                    circular: true),
                const SizedBox(width: 14),
                _ShimmerBlock(
                    width: 130, height: 16, colorScheme: colorScheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: AppTheme.doubleBezel(
        colorScheme: colorScheme,
        isDark: isDark,
        outerRadius: 28,
        outerBorderColor: colorScheme.error.withValues(alpha: 0.2),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.doubleBezelInner(
          colorScheme: colorScheme,
          isDark: isDark,
          radius: 25,
          color: colorScheme.errorContainer.withValues(alpha: 0.15),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.error.withValues(alpha: 0.15),
                ),
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                  color: colorScheme.error.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 28,
                  color: colorScheme.error.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Couldn't load quote",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _fetchQuote,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: colorScheme.error.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded,
                          size: 16, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Try again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme colorScheme;
  final bool circular;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.colorScheme,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circular ? height : (width != double.infinity ? width : null),
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: circular
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(8),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _NextButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: 60,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.85),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLoading ? 'Loading...' : 'Next inspiration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: Icon(
                  isLoading ? Icons.hourglass_empty_rounded : Icons.arrow_forward_rounded,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
