import 'dart:convert';

class Article {
  final int id;
  final String title;
  final bool isFavorite;

  const Article({
    required this.id,
    required this.title,
    this.isFavorite = false,
  });

  factory Article.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final title = json['title'];
    final favorite = json['favorite'];
    if (id is! int || title is! String || favorite is! bool) {
      throw const FormatException('Invalid article fields');
    }
    return Article(id: id, title: title, isFavorite: favorite);
  }

  Article copyWith({bool? isFavorite}) =>
      Article(id: id, title: title, isFavorite: isFavorite ?? this.isFavorite);
}

abstract interface class ArticleRepository {
  Future<List<Article>> load();
  void setFavorite({required int id, required bool value});
}

class MemoryArticleRepository implements ArticleRepository {
  final List<Article> _articles;

  MemoryArticleRepository() : _articles = _readSeed();

  static List<Article> _readSeed() {
    const source = '''
    [
      {"id": 1, "title": "Dart basics", "favorite": false},
      {"id": 2, "title": "Flutter widgets", "favorite": true}
    ]
    ''';
    final Object? decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array');
    }
    return decoded.map((Object? item) {
      if (item is! Map<String, Object?>) {
        throw const FormatException('Expected an article object');
      }
      return Article.fromJson(item);
    }).toList();
  }

  @override
  Future<List<Article>> load() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return List<Article>.unmodifiable(_articles);
  }

  @override
  void setFavorite({required int id, required bool value}) {
    final index = _articles.indexWhere((article) => article.id == id);
    if (index == -1) {
      throw ArgumentError.value(id, 'id', 'Article not found');
    }
    _articles[index] = _articles[index].copyWith(isFavorite: value);
  }
}

Future<void> main() async {
  final ArticleRepository repository = MemoryArticleRepository();
  final before = await repository.load();
  print('before=${before.where((article) => article.isFavorite).length}');

  repository.setFavorite(id: 1, value: true);
  final after = await repository.load();
  final titles = after
      .where((article) => article.isFavorite)
      .map((article) => article.title)
      .toList();
  print('after=$titles');
  print('old snapshot favorite=${before.first.isFavorite}');

  try {
    repository.setFavorite(id: 99, value: true);
  } on ArgumentError catch (error) {
    print('handled=${error.message}');
  }
}
