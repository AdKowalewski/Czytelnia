import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './book.dart';

class BookLib extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookLibState();
  }
}

class BookLibState extends State<BookLib> {
  // final List<Book> books = [
  //   Book(id: '1', title: 'harry potter', cover: 'fdfadsffa'),
  //   Book(id: '2', title: 'lotr', cover: 'sfdsfdsfd'),
  //   Book(id: '3', title: 'diuna', cover: 'sfasdfadsf'),
  // ];

  Future<Book> fetchBooks() async {
    final response = await http.get(Uri.parse('./assets/books.json'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Book.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteka książek'),
      ),
      body: Center(
          child: Column(
        children: books.map((book) {
          return Card(
            child: Column(
              children: [
                Text('Id: ' + book.id),
                Text('Tytuł: ' + book.title),
                Text('Okładka: ' + book.cover),
              ],
            ),
          );
        }).toList(),
      )),
    );
  }
}
