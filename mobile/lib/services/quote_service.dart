import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';
import 'api_config.dart';

class QuoteService {
  final http.Client _client;

  QuoteService({http.Client? client}) : _client = client ?? http.Client();

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/quotes/random'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Quote.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch quote (${response.statusCode})');
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('Connection refused')) {
        throw Exception('Unable to connect to server. Please check your connection.');
      }
      rethrow;
    }
  }

  Future<List<Quote>> fetchQuotesByCategory(String category) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/quotes/category/$category'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Failed to fetch category quotes (${response.statusCode})');
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('Connection refused')) {
        throw Exception('Unable to connect to server.');
      }
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/quotes/categories'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((e) => e as String).toList();
      }
      return _defaultCategories();
    } catch (_) {
      return _defaultCategories();
    }
  }

  List<String> _defaultCategories() {
    return [
      'inspiration',
      'wisdom',
      'success',
      'life',
      'love',
      'friendship',
      'creativity',
      'humor',
    ];
  }

  void dispose() {
    _client.close();
  }
}
