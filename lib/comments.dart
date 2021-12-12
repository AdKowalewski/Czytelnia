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
  //String _error = "";

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

  void showError(message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
      ));
  }

  void fetchComments() async {
    setState(() {
      _loading = true;
    });
    var response;
    try {
      response = await http
          .get(Uri.parse(
              'http://10.0.2.2:8000/api/comments/' + widget.bookId.toString()))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      showError("Nie udało się połączyć z serwerem");
      return;
    }

    if (response.statusCode == 200) {
      Iterable i = jsonDecode(response.body);
      List<Comment> newComments =
          List<Comment>.from(i.map((json) => Comment.fromJson(json)));
      setState(() {
        comments = comments + newComments;
      });
    } else {
      showError(jsonDecode(response.body)['detail']);
    }
    setState(() {
      _loading = false;
    });
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
    if (_loading) {
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
  String _reviewText = "";
  bool? _review;

  bool _loading = false;
  //String _error = "";

  @override
  void initState() {
    debugPrint("PRZED");
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getUserComment();
    });
    super.initState();
    
    debugPrint("PO");
    //controller.addListener(_scrollListener);
  }

  void showError(message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
      ));
  }

  void postComment() async {
    setState(() {
      _loading = true;
    });
    var response;
    try {
      final token = Provider.of<UserState>(context, listen: false).token;
      response = await http.put(
          Uri.parse('http://10.0.2.2:8000/api/comments/${widget.bookId}'),
          body: jsonEncode(<String, String>{
            'text': _reviewText,
            'review': _review.toString()
          }),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          }).timeout(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      showError("Nie udało się połączyć z serwerem");
      return;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      showError("Wysłano pomyślnie");
    } else {
      showError(jsonDecode(response.body['detail']));
    }
    setState(() {
      _loading = false;
    });
  }

  void getUserComment() async {
    setState(() {
      _loading = true;
    });
    var response;
    try {
      final token = Provider.of<UserState>(context, listen: false).token;
      response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/comments/${widget.bookId}/user'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          }).timeout(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      showError("Nie udało się połączyć z serwerem!");
      return;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final comm = Comment.fromJson(jsonDecode(response.body));
      debugPrint(comm.text);
      setState(() {
        _reviewText = comm.text;
        _review = comm.review;
      });
    }
    else{
      showError(jsonDecode(response.body['detail']));
    }
    setState(() {
      _loading = false;
    });
  }

  Widget getForm(){
    return Form(
      key: _formKey,
      child: Wrap(
        children: <Widget>[
          const Text("Treść recenzji"),
          TextFormField(
            initialValue: _reviewText,
            maxLines: 10,
            onChanged: (text) {
              _reviewText = text;
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
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return CheckboxListTile(
                value: _review,
                tristate: true,
                onChanged: (val) {
                  setState(() {
                    print(_review);
                    _review = val;
                  });
                });
          }),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  postComment();
                }
              },
              child: const Text("Wyślij")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_loading){
      return const CircularProgressIndicator();
    }
    else{
      return getForm();
    }
  }
}
