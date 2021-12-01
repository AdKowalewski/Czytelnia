import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './comments.dart';
import './book.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
