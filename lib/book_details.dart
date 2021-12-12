import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
  bool _comms = false;
  bool? _isFavorite;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      isFavorite();
    });
  }

  Widget BookInfo() {
    return Column(children: [
      Text(
        'Autor: ' + widget.author,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      Card(
        child: AspectRatio(
          aspectRatio: 1 / 1.5,
          //aspectRatio: constraints.maxWidth / (constraints.maxHeight / 1.23),
          child: Image.network(
            widget.coverUrl,
            fit: BoxFit.fill,
          ),
        ),
      ),
      // Card(child: Text(widget.content)),
    ]);
  }

  Widget CommentBar() {
    return Container(
        //color: Colors.blueAccent,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      OutlinedButton(
          child: const Text('Napisz recenzję'),
          onPressed: () {
            setState(() {
              _comms = false;
            });
          }),
      OutlinedButton(
          child: const Text('Czytaj recenzje'),
          onPressed: () {
            setState(() {
              _comms = true;
            });
          }),
    ]));
  }

  void toggleFavorite() async {
    var response;
    try {
      final token = Provider.of<UserState>(context, listen: false).token;
      response = await http.put(
          Uri.parse('http://10.0.2.2:8000/api/users/favorite/${widget.id}'),
          headers: <String, String>{
            'Authorization': 'Bearer $token',
          });
    } catch (e) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      setState(() {
        _isFavorite = !_isFavorite!;
      });
    } else {
      debugPrint('NIE POSZŁO');
    }
  }

  void isFavorite() async {
    var response;
    final token = Provider.of<UserState>(context, listen: false).token;
    response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/favorite/${widget.id}'),
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

  Widget Favorites_star() {
    return IconButton(
      icon: _isFavorite!
          ? Icon(
              Icons.star,
              color: Colors.yellow,
            )
          : Icon(
              Icons.star_border,
              color: Colors.yellow,
            ),
      tooltip: 'Add to favorites',
      onPressed: () {
        toggleFavorite();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[Favorites_star()],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            BookInfo(),
            CommentBar(),
            _comms ? Comments(widget.id) : CommentForm(widget.id)
          ],
        )));
  }
}
