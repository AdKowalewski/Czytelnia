import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import './globals.dart' as globals;
import './comments.dart';
import './book.dart';
import './user_state.dart';

class BookDetails extends StatefulWidget {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  //final String content;

  // BookDetails(
  //     {required Key key,
  //     required this.title,
  //     required this.author,
  //     required this.coverUrl,
  //     required this.content,
  //     required this.comments})
  //     : super(key: key);

  BookDetails({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
  });

  @override
  BookDetailsState createState() => BookDetailsState();
}

class BookDetailsState extends State<BookDetails> {
  bool _loadingComments = false;
  String _commentsError = "";
  bool? _comms = null;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    debugPrint(widget.coverUrl);
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (Provider.of<UserState>(context, listen: false).loggedIn) {
        isFavorite();
      }
    });
  }

  Widget BookInfo() {
    return DecoratedBox(
      position: DecorationPosition.background,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: Colors.grey,
          style: BorderStyle.solid,
          width: 1.0,
        ),
        borderRadius: BorderRadius.zero,
        shape: BoxShape.rectangle,
      ),
      child: Container(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            "${globals.baseURL}/api/books/cover/${widget.id}",
                            width: constraints.maxWidth / 2.5,
                          ),
                        ),
                        //const VerticalDivider(color: Colors.grey, thickness: 5),
                        Column(children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            widget.author,
                            style: TextStyle(fontSize: 20),
                          ),
                        ])
                      ]),
                  const Divider(color: Colors.grey, thickness: 1),
                  Text(
                    "Tymczasowy opis książki",
                    style: TextStyle(fontSize: 15),
                  ),
                  //const Divider(color: Colors.grey, thickness: 1.5)
                ]);
          })),
    );
  }

  Widget commentBlock() {
    if (_comms == null) {
      return const SizedBox.shrink();
    } else {
      return _comms! ? Comments(widget.id) : CommentForm(widget.id);
    }
  }

  Widget commentBar() {
    return Container(
      padding: EdgeInsets.all(10),
      child: DecoratedBox(
          position: DecorationPosition.background,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(
              color: Colors.grey,
              style: BorderStyle.solid,
              width: 1.0,
            ),
            borderRadius: BorderRadius.zero,
            shape: BoxShape.rectangle,
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Consumer<UserState>(builder: (context, state, child) {
                  return state.loggedIn
                      ? Expanded(
                          child: OutlinedButton(
                              child: const Text('Napisz recenzję'),
                              onPressed: () {
                                setState(() {
                                  _comms = false;
                                });
                              }),
                        )
                      : const SizedBox.shrink();
                }),
                Expanded(
                  child: OutlinedButton(
                      child: const Text('Czytaj recenzje'),
                      onPressed: () {
                        setState(() {
                          _comms = true;
                        });
                      }),
                ),
              ]),
            ),
            commentBlock()
          ])),
    );
  }

  void toggleFavorite() async {
    var response;
    try {
      final token = Provider.of<UserState>(context, listen: false).token;
      response = await http.put(
          Uri.parse('${globals.baseURL}/api/users/favorite/${widget.id}'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          });
    } catch (e) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } else {
      debugPrint('NIE POSZŁO');
    }
  }

  void isFavorite() async {
    var response;
    final token = Provider.of<UserState>(context, listen: false).token;
    response = await http.get(
        Uri.parse('${globals.baseURL}/api/users/favorite/${widget.id}'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        });
    Map<String, dynamic> jsonData = await jsonDecode(response.body);
    if (jsonData['fav'] == true) {
      setState(() {
        _isFavorite = true;
      });
    } else {
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Widget favoritesStar() {
    return Consumer<UserState>(builder: (context, state, child) {
      return state.loggedIn
          ? IconButton(
              icon: _isFavorite
                  ? const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    )
                  : const Icon(
                      Icons.star_border,
                      color: Colors.yellow,
                    ),
              tooltip: 'Add to favorites',
              onPressed: () {
                toggleFavorite();
              },
            )
          : const SizedBox.shrink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[favoritesStar()],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            BookInfo(),
            commentBar(),
          ],
        )));
  }
}
