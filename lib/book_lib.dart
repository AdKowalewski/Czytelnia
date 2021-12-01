import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './book.dart';
import './book_details.dart';

class BookLib extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookLibState();
  }
}

class BookLibState extends State<BookLib> {
  final controller = ScrollController();
  List<Book> books = [];
  int _page = 1;
  bool _loading = false;
  String _error = "";

  @override
  void initState() {
    super.initState();
    debugPrint("PRZED");
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      fetchBooks();
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
      fetchBooks();
    }
  }

  void fetchBooks() async {
    setState(() {
      _loading = true;
      _error = "";
    });
    var response;
    try {
      response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/books?page_num=$_page'))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _error = "Nie udało się połączyć z serwerem";
      });
      return;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable i = jsonDecode(response.body);
      List<Book> newBooks =
          List<Book>.from(i.map((json) => Book.fromJson(json)));
      setState(() {
        books = books + newBooks;
      });
      _page++;
    } else {
      setState(() {
        _error = jsonDecode(response.body['detail']);
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

  Widget BookGrid() {
    //return Scrollbar(
    //controller: controller,
    //isAlwaysShown: true,
    return GridView.count(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      //controller: controller,
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      crossAxisCount: 2,
      children: books.map((book) {
        return Expanded(
          child: InkWell(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Column(
                    children: [
                      AspectRatio(
                        aspectRatio: constraints.maxWidth /
                            (constraints.maxHeight / 1.23),
                        child: Image.network(
                          "http://10.0.2.2:8000/api/books/${book.id}/cover",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Text(''),
                      Flexible(
                          child: Text(
                        'Tytuł: ' + book.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      Flexible(child: Text('Autor: ' + book.author)),
                    ],
                  );
                }),
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return BookDetails(
                  id: book.id,
                  title: book.title,
                  author: book.author,
                  coverUrl: "http://10.0.2.2:8000/api/books/${book.id}/cover",
                  // content: null,
                  // comments: null,
                );
              }));
            },
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
      return BookGrid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteka książek'),
      ),
      body: getWidget(),
    );
  }
}
