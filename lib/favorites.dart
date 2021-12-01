import 'dart:convert';
import 'package:czytelnia/user_state.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import './book.dart';
import './book_details.dart';
import './pdf_view.dart';

class Favorites extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FavoritesState();
  }
}

class FavoritesState extends State<Favorites> {
  List<Book> books = [];
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

  void fetchBooks() async {
    setState(() {
      _loading = true;
    });
    setState(() {
      _error = false;
    });
    var response;
    final token = Provider.of<UserState>(context, listen: false).token;
    response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/users/favorite'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );
    // try {

    // } catch (e) {
    //   setState(() {
    //     _error = true;
    //   });
    // }

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

  Widget BookList() {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10),
      children: books.map((book) {
        return Expanded(
          child: InkWell(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: new LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Row(
                    children: [
                      /*AspectRatio(
                        aspectRatio: constraints.maxWidth /
                            (constraints.maxHeight / 1.23),
                        child: Image.network(
                          "http://10.0.2.2:8000/api/books/${book.id}/cover",
                          fit: BoxFit.fill,
                        ),
                      ),*/
                      Image.network(
                        "http://10.0.2.2:8000/api/books/${book.id}/cover",
                        width: 75,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          child: Text(
                        'Tytuł: ' + book.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(child: Text('Autor: ' + book.author)),
                    ],
                  );
                }),
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return PDFView(
                  book.id,
                );
              }));
            },
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
      return BookList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione książki'),
      ),
      body: getWidget(),
    );
  }
}
