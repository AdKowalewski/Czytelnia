import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Column(children: [
            Text(
              'Autor: ' + widget.author,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Card(
              child: AspectRatio(
                aspectRatio:
                    constraints.maxWidth / (constraints.maxHeight / 1.23),
                child: Image.network(
                  widget.coverUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Card(child: Text(widget.content)),
            Comments(
              bookId: widget.id,
            ),
          ]);
        }));
  }
}
