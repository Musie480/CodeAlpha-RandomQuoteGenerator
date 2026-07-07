import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/quote_card.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Quote of the moment',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daily inspiration',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                _buildLoadingState(theme, colorScheme)
              else if (_error != null)
                _buildErrorState(theme, colorScheme)
              else if (_currentQuote != null)
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(_entryAnim),
                  child: FadeTransition(
                    opacity: _entryAnim,
                    child: QuoteCard(
                      quote: _currentQuote!,
                      isFavorite:
                          context.watch<FavoritesProvider>().isFavorite(_currentQuote!),
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
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isLoading || _currentQuote == null
                          ? null
                          : _fetchQuote,
                      icon: const Icon(Icons.auto_awesome_outlined, size: 22),
                      label: const Text('Next inspiration'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.surfaceContainerLow,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBlock(width: 40, height: 40, colorScheme: colorScheme),
              const SizedBox(height: 20),
              _ShimmerBlock(
                  width: double.infinity, height: 18, colorScheme: colorScheme),
              const SizedBox(height: 10),
              _ShimmerBlock(
                  width: 0.7, height: 18, colorScheme: colorScheme),
              const SizedBox(height: 26),
              Row(
                children: [
                  _ShimmerBlock(width: 3, height: 28, colorScheme: colorScheme),
                  const SizedBox(width: 14),
                  _ShimmerBlock(
                      width: 130, height: 16, colorScheme: colorScheme),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.errorContainer.withValues(alpha: 0.3),
            border: Border.all(
              color: colorScheme.error.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: colorScheme.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Couldn\'t load quote',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _fetchQuote,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme colorScheme;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width != double.infinity ? width : null,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
