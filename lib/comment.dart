class Comment {
  final int id;
  final int userId;
  final String username;
  final String text;
  final bool review;
  final String createdAt;
  final bool modified;
  final String modifiedAt;

  Comment(
      {required this.id,
      required this.userId,
      required this.username,
      required this.text,
      required this.review,
      required this.createdAt,
      required this.modified,
      required this.modifiedAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user']['id'],
      username: json['user']['username'],
      text: json['text'],
      review: json['review'],
      createdAt: json['created_at'],
      modified: json['modified'],
      modifiedAt: json['modified_at'],
    );
  }
}
