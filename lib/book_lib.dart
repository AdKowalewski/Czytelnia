import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './globals.dart' as globals;
import './book.dart';
import './book_details.dart';

class BookLib extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookLibState();
  }
}

class BookLibState extends State<BookLib> {
  //final controller = ScrollController();
  List<Book> books = [];
  int _page = 1;
  bool _loading = false;
  bool fetchDisabled = false;
  Timer? fetchDelay;
  //String _error = "";

  void delayFetch() {
    fetchDisabled = true;
    if (fetchDelay != null) {
      fetchDelay!.cancel();
    }
    fetchDelay = Timer(const Duration(seconds: 4), () {
      fetchDisabled = false;
    });
  }

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

  // @override
  // void dispose() {
  //   controller.removeListener(_scrollListener);
  //   super.dispose();
  // }

  // void _scrollListener() {
  //   if (controller.position.extentAfter < 500) {
  //     fetchBooks();
  //   }
  // }

  void showError(message, {dur = 2000}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), duration: Duration(milliseconds: dur)));
  }

  void fetchBooks() async {
    setState(() {
      _loading = true;
      //_error = "";
    });
    var response;
    try {
      response = await http
          .get(Uri.parse('${globals.baseURL}/api/books/list?page_num=$_page'))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      showError("Nie udało się połączyć z serwerem");
      return;
    }

    final int code = response.statusCode;
    if (code >= 200 && code < 300) {
      if (code == 200) {
        Iterable i = jsonDecode(response.body);
        List<Book> newBooks =
            List<Book>.from(i.map((json) => Book.fromJson(json)));
        setState(() {
          books = books + newBooks;
        });
        _page++;
      } else {
        showError("Nie ma więcej książek", dur: 500);
      }
    } else {
      showError(jsonDecode(response.body)['detail'].toString());
    }
    setState(() {
      _loading = false;
    });
  }

  // Widget ErrorBox() {
  //   return Text(_error);
  // }

  Widget Spinner() {
    return const CircularProgressIndicator();
  }

  Widget BookGrid() {
    //return Scrollbar(
    //controller: controller,
    //isAlwaysShown: true,
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      //physics: const ScrollPhysics(),
      scrollDirection: Axis.vertical,
      //controller: controller,
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
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  children: [
                    AspectRatio(
                      aspectRatio:
                          constraints.maxWidth / (constraints.maxHeight / 1.23),
                      child: Image.network(
                        "${globals.baseURL}/api/books/cover/${book.id}",
                        fit: BoxFit.fill,
                      ),
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    Flexible(
                        child: Text(book.title,
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    //Flexible(child: Text('Autor: ' + book.author)),
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
                coverUrl: "${globals.baseURL}" + book.cover,
                //coverUrl: "${globals.baseURL}/api/books/cover/${book.id}",
                // content: null,
                // comments: null,
              );
            }));
          },
        );
      }).toList(),
    );
  }

  // Widget BookGrid() {
  //   //return Scrollbar(
  //   //controller: controller,
  //   //isAlwaysShown: true,
  //   return Wrap(
  //     children: books.map((book) {
  //       return InkWell(
  //         child: Card(
  //           child: Padding(
  //               padding: EdgeInsets.all(10),
  //               child: Column(
  //                 children: [
  //                   Image.network(
  //                     "${globals.baseURL}/api/books/${book.id}/cover",
  //                   ),
  //                   const Divider(thickness: 1, color: Colors.grey),
  //                   Flexible(
  //                       child: Text(book.title,
  //                           style: TextStyle(fontWeight: FontWeight.bold))),
  //                   //Flexible(child: Text('Autor: ' + book.author)),
  //                 ],
  //               )),
  //         ),
  //         onTap: () {
  //           Navigator.push(context,
  //               MaterialPageRoute<void>(builder: (BuildContext context) {
  //             return BookDetails(
  //               id: book.id,
  //               title: book.title,
  //               author: book.author,
  //               coverUrl: "${globals.baseURL}/api/books/${book.id}/cover",
  //               // content: null,
  //               // comments: null,
  //             );
  //           }));
  //         },
  //       );
  //     }).toList(),
  //   );
  // }

  Widget getWidget() {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              !_loading &&
              !fetchDisabled) {
            delayFetch();
            fetchBooks();
          }
          return true;
        },
        child: SingleChildScrollView(
            physics: const ScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(children: <Widget>[
              BookGrid(),
              _loading ? Spinner() : const SizedBox.shrink()
            ])));
    // return Column(children: [
    //   NotificationListener<ScrollNotification>(
    //       onNotification: (ScrollNotification scrollInfo) {
    //         if (scrollInfo.metrics.pixels ==
    //                 scrollInfo.metrics.maxScrollExtent &&
    //             !_loading) {
    //           fetchBooks();
    //         }
    //         return false;
    //       },
    //       child: BookGrid()),
    //   _loading ? Spinner() : const SizedBox.shrink()
    // ]);
  }

  // Widget getWidget() {
  //   // if (_error.isNotEmpty) {
  //   //return Center(child: ErrorBox());
  //   if (_loading) {
  //     return Center(child: Spinner());
  //   } else {
  //     return NotificationListener<ScrollNotification>(
  //         onNotification: (ScrollNotification scrollInfo) {
  //           if (scrollInfo.metrics.pixels ==
  //                   scrollInfo.metrics.maxScrollExtent &&
  //               !_loading) {
  //             fetchBooks();
  //           }
  //           return false;
  //         },
  //         child: BookGrid());
  //   }
  // }

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
