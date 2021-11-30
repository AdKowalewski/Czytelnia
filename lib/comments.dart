import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:czytelnia/user_state.dart';
import './comment.dart';

class Comments extends StatefulWidget {
  int bookId;
  Comments(this.bookId);

  @override
  CommentsState createState() => CommentsState();
}

class CommentsState extends State<Comments> {
  ScrollController controller = ScrollController();
  List<Comment> comments = [];
  bool _loading = false;
  String _error = "";

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
      _error = "";
    });
    var response;
    try {
      response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/comments/get/' +
              widget.bookId.toString()))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      _loading = false;
      _error = "Nie udało się połączyć z serwerem";
    }

    if (response.statusCode == 200) {
      Iterable i = jsonDecode(response.body);
      List<Comment> newComments =
          List<Comment>.from(i.map((json) => Comment.fromJson(json)));
      setState(() {
        comments = comments + newComments;
      });
    } else {
      setState(() {
        _error = jsonDecode(response.body)['detail'];
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Widget ErrorBox() {
    return Text(_error);
  }

  Widget Spinner() {
    return const CircularProgressIndicator();
  }

  Widget CommentList() {
    return Column(
      children: comments.map((comment) {
        return Card(
          child: Column(
            children: [
              Card(child: Text(comment.username)),
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
    if (_error.isNotEmpty) {
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

class CommentForm extends StatefulWidget {
  int bookId;
  CommentForm(this.bookId, {Key? key}) : super(key: key);
  //LoginForm({Key? key}, this.isLogin) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _formKey = GlobalKey<FormState>();
  String reviewText = "";
  bool? review;

  bool _loading = false;
  String _error = "";

  @override
  Widget build(BuildContext context) {
    void editComment() async {
      setState(() {
        _loading = true;
        _error = "";
      });
      var response;
      try {
        final token = Provider.of<UserState>(context, listen: false).token;
        response = await http.post(
            Uri.parse(
                'http://10.0.2.2:8000/api/comments/edit/${widget.bookId}'),
            body: jsonEncode(<String, String>{
              'text': reviewText,
              'review': review.toString()
            }),
            headers: <String, String>{
              'Authorization': 'Bearer $token',
            }).timeout(const Duration(seconds: 2));
      } catch (e) {
        setState(() {
          _error = "Nie udało się połączyć z serwerem";
        });
        return;
      }

      if (response.statusCode == 204) {
        setState(() {
          _error = "Przesłano pomyślnie";
        });
      } else {
        setState(() {
          _error = jsonDecode(response.body['detail']);
        });
      }
      setState(() {
        _loading = false;
      });
    }

    return Form(
      key: _formKey,
      child: Wrap(
        children: <Widget>[
          const Text("Treść recenzji"),
          TextFormField(
            maxLines: 10,
            onChanged: (text) {
              reviewText = text;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Recenzja nie może być pusta';
              }
              return null;
            },
          ),
          const SizedBox(height: 100),
          const Text("Ocena"),
          Checkbox(
              value: null,
              tristate: true,
              onChanged: (val) {
                review = val;
              }),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  editComment();
                }
              },
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Wysyłanie"),
                          SizedBox(
                            width: 5,
                          ),
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                              backgroundColor: Colors.blue,
                              strokeWidth: 3,
                            ),
                          )
                        ],
                      ),
                    )
                  : const Text("Wyślij")),
          //const SizedBox(height: 50),
          _error.isNotEmpty
              ? const Divider(color: Colors.grey, thickness: 1.5)
              : const SizedBox.shrink(),
          _error.isNotEmpty ? Text(_error) : const SizedBox.shrink()
        ],
      ),
    );
  }
//id, user, text, review, cre-at, modifeied, mod-at
}
