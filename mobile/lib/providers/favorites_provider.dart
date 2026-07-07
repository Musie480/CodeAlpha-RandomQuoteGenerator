import 'package:flutter/foundation.dart';
import '../models/quote.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Quote> _favorites = [];

  List<Quote> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(Quote quote) {
    return _favorites.any((f) => f.id == quote.id);
  }

  void toggleFavorite(Quote quote) {
    if (isFavorite(quote)) {
      _favorites.removeWhere((f) => f.id == quote.id);
    } else {
      _favorites.add(quote);
    }
    notifyListeners();
  }

  void removeFavorite(int quoteId) {
    _favorites.removeWhere((f) => f.id == quoteId);
    notifyListeners();
  }
}
