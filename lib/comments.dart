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

  void showError(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: comments.map((comment) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            comment.username,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        comment.review
                            ? const Icon(Icons.thumb_up_outlined,
                                color: Colors.green)
                            : const Icon(Icons.thumb_down_outlined,
                                color: Colors.red),
                        Column(
                          children: [
                            Text("Utworzono : ${comment.createdAt.toString()}"),
                            comment.modified
                                ? Text(
                                    "Zmodyfikowano : ${comment.modifiedAt.toString()}")
                                : const SizedBox.shrink(),
                          ],
                        )
                      ]),
                  const Divider(thickness: 1, color: Colors.grey),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      comment.text,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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
  bool _review = true;
  bool _doesReviewExist = false;

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

  void showError(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      setState(() {
        _doesReviewExist = true;
      });
    } else {
      showError(jsonDecode(response.body['detail']));
      setState(() {
        _doesReviewExist = false;
      });
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
      if (response.statusCode == 204) {
        debugPrint('204');
        setState(() {
          _reviewText = "";
          _review = true;
          _loading = false;
          _doesReviewExist = false;
        });
      } else {
        final comm = Comment.fromJson(jsonDecode(response.body));
        debugPrint(comm.text);
        debugPrint('not 204');
        setState(() {
          _reviewText = comm.text;
          _review = comm.review;
          _loading = false;
          _doesReviewExist = true;
        });
      }
    } else {
      showError(jsonDecode(response.body['detail']));
    }
    setState(() {
      _loading = false;
    });
  }

  void deleteComment() async {
    setState(() {
      _loading = true;
    });
    var response;
    try {
      final token = Provider.of<UserState>(context, listen: false).token;
      response = await http.delete(
          Uri.parse('http://10.0.2.2:8000/api/comments/${widget.bookId}'),
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
      showError("Usunięto pomyślnie");
      setState(() {
        _reviewText = "";
        _review = true;
        _loading = false;
        _doesReviewExist = false;
      });
    } else {
      showError(jsonDecode(response.body['detail']));
    }
    setState(() {
      _loading = false;
    });
  }

  Widget RedDeleteButton() {
    if (_doesReviewExist) {
      return Container(
        margin: const EdgeInsets.only(left: 10.0),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                deleteComment();
              }
            },
            child: const Text("Usuń")),
      );
    } else {
      return Container();
    }
  }

  Widget textOnBlueButton() {
    if (_doesReviewExist) {
      return const Text('Edytuj');
    } else {
      return const Text('Wyślij');
    }
  }

  Widget getForm() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Form(
        key: _formKey,
        child: Wrap(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Treść recenzji",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(),
                ),
                //fillColor: Colors.green
              ),
              initialValue: _reviewText,
              maxLines: 5,
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
            //const Text("Ocena"),
            CheckboxListTile(
                title: const Text("Ocena"),
                value: _review,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  setState(() {
                    print(_review);
                    _review = val!;
                  });
                }),
            // Checkbox(
            //   checkColor: Colors.white,
            //   value: _review,
            //   onChanged: (bool? value) {
            //     setState(() {
            //       _review = value!;
            //     });
            //   },
            // ),
            const SizedBox(height: 50),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          postComment();
                        }
                      },
                      child: textOnBlueButton()),
                ),
                RedDeleteButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    } else {
      return getForm();
    }
  }
}
