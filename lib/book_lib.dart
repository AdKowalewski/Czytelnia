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
  ScrollController controller = ScrollController();
  List<Book> books = [
    // Book(id: 1, author: 'sadsad', title: 'harry potter', cover: 'fdfadsffa'),
    // Book(id: 2, author: 'sadsad', title: 'lotr', cover: 'sfdsfdsfd'),
    // Book(id: 3, author: 'sadsad', title: 'diuna', cover: 'sfasdfadsf'),
    // Book(id: 1, author: 'sadsad', title: 'diuna', cover: 'sfasdfadsf'),
    // Book(id: 1, author: 'sadsad', title: 'diuna', cover: 'sfasdfadsf'),
    // Book(id: 1, author: 'sadsad', title: 'diuna', cover: 'sfasdfadsf'),
  ];
  int _page = 1;
  bool _loading = false;
  bool _error = false;

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
    });
    setState(() {
      _error = false;
    });
    var response;
    response = await http
        .get(Uri.parse('http://127.0.0.1:8000/api/books/get?page_num=$_page'));
    // try {

    // } catch (e) {
    //   setState(() {
    //     _error = true;
    //   });
    // }

    if (response.statusCode == 200) {
      Iterable i = jsonDecode(response.body);
      List<Book> newBooks =
          List<Book>.from(i.map((json) => Book.fromJson(json)));
      setState(() {
        books = books + newBooks;
      });
      _page++;
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
    if (_error) {
      return const Text("Nie udało się wczytać!!!");
    } else {
      return Container();
    }
  }

  Widget Spinner() {
    if (_loading) {
      return const Text("ładuję");
    } else {
      return Container();
    }
  }

  Widget BookGrid() {
    //return Scrollbar(
    //controller: controller,
    //isAlwaysShown: true,
    return GridView.count(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      //scrollDirection: Axis.vertical,
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
      crossAxisCount: 2,
      children: books.map((book) {
        return InkWell(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: new LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio:
                          constraints.maxWidth / (constraints.maxHeight / 1.23),
                      child: Image.network(
                        "http://127.0.0.1:8000/api/books/get_cover/${book.id}",
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
                title: book.title,
                author: book.author,
                coverUrl:
                    "http://127.0.0.1:8000/api/books/get_cover/${book.id}",
                // content: null,
                // comments: null,
              );
            }));
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteka książek'),
        ),
        body: Column(
          children: [BookGrid(), Spinner(), ErrorBox()],
        ));
  }
}
