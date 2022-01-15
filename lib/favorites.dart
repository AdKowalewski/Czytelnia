import 'dart:convert';
import 'package:czytelnia/user_state.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import './globals.dart' as globals;
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
  bool _loading = false;
  //bool _error = false;

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

  void showError(message, {dur = 2000}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), duration: Duration(milliseconds: dur)));
  }

  void fetchBooks() async {
    setState(() {
      _loading = true;
    });
    var response;
    final token = Provider.of<UserState>(context, listen: false).token;
    try {
      response = await http.get(
        Uri.parse('${globals.baseURL}/api/users/favorite'),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      showError("Nie udało się połączyć z serwerem");
      return;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      Iterable i = jsonDecode(response.body);
      List<Book> newBooks =
          List<Book>.from(i.map((json) => Book.fromJson(json)));
      setState(() {
        books = books + newBooks;
      });
    } else {
      showError(jsonDecode(response.body)['detail'].toString());
    }
    setState(() {
      _loading = false;
    });
  }

  Widget BookList() {
    return ListView(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(10),
      children: books.map((book) {
        return InkWell(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      Image.network(
                        "${globals.baseURL}/api/books/cover/${book.id}",
                        width: constraints.maxWidth / 4,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    book.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                const Divider(thickness: 1, color: Colors.grey),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    book.author,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ]),
                        ),
                      )
                    ],
                  ),
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
        );
      }).toList(),
    );
  }

  Widget getWidget() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
