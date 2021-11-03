class Book {
  final String id;
  final String title;
  final String cover;

  Book({
    required this.id,
    required this.title,
    required this.cover,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      cover: json['cover'],
    );
  }
}
