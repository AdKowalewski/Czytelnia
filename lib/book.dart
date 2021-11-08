class Book {
  final int id;
  final String author;
  final String title;
  final String cover;

  Book({
    required this.id,
    required this.author,
    required this.title,
    required this.cover,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      cover: json['cover'],
    );
  }
}
