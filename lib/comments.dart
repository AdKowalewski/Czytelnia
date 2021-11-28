import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './comment.dart';
import 'dart:convert';

class Comments extends StatefulWidget {
  final int bookId;

  const Comments({required this.bookId});

  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  ScrollController controller = ScrollController();
  List<Comment> comments = [];
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    debugPrint("PRZED");
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      fetchComments();
    });
    debugPrint("PO");
    //controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500) {
      fetchComments();
    }
  }

  void fetchComments() async {
    setState(() {
      _loading = true;
    });
    setState(() {
      _error = false;
    });
    var response;
    response = await http.get(Uri.parse(
        'http://127.0.0.1:8000/api/comments/get/' + widget.bookId.toString()));
    // try {

    // } catch (e) {
    //   setState(() {
    //     _error = true;
    //   });
    // }

    if (response.statusCode == 200) {
      Iterable i = jsonDecode(response.body);
      List<Comment> newComments =
          List<Comment>.from(i.map((json) => Comment.fromJson(json)));
      setState(() {
        comments = comments + newComments;
      });
    } else {
      setState(() {
        _error = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Widget ErrorBox() {
    // if (_error) {
    //   return const Text("Nie udało się wczytać!!!");
    // } else {
    //   return Container();
    // }
    return const Text("Nie udało się wczytać!!!");
  }

  Widget Spinner() {
    // if (_loading) {
    //   return const Text("ładuję");
    // } else {
    //   return Container();
    // }
    return CircularProgressIndicator();
  }

  Widget CommentList() {
    return Column(
      children: comments.map((comment) {
        return Card(
          child: Column(
            children: [
              Card(child: Text(comment.user.toString())),
              Card(child: Text(comment.text)),
              Row(
                children: [
                  Card(
                    child: Text(comment.review.toString()),
                  ),
                  Card(
                    child: Text(comment.modified
                        ? comment.modifiedAt.toString()
                        : comment.createdAt.toString()),
                  ),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget getWidget() {
    if (_error) {
      return Center(child: ErrorBox());
    } else if (_loading) {
      return Center(child: Spinner());
    } else {
      return CommentList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return getWidget();
  }
}

//id, user, text, review, cre-at, modifeied, mod-at
