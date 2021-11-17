class Comment {
  final int id;
  final String user;
  final String text;
  final bool review;
  final DateTime createdAt;
  final bool modified;
  final DateTime modifiedAt;

  Comment(
      {required this.id,
      required this.user,
      required this.text,
      required this.review,
      required this.createdAt,
      required this.modified,
      required this.modifiedAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: json['user'],
      text: json['text'],
      review: json['review'],
      createdAt: json['created_at'],
      modified: json['modified'],
      modifiedAt: json['modified_at'],
    );
  }
}
