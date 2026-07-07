class Quote {
  final int id;
  final String text;
  final String author;
  final String category;

  const Quote({
    required this.id,
    required this.text,
    required this.author,
    this.category = 'general',
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      text: json['quote'] as String,
      author: json['author'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote': text,
      'author': author,
      'category': category,
    };
  }
}
