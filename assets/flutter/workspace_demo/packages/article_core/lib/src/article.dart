class Article {
  final String title;
  const Article(this.title);
  String get label => _normalize(title);
}

String _normalize(String value) => value.trim();
