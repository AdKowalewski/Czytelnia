/// Flutter code sample for AppBar

// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './favorites.dart';
import './book_lib.dart';
import './auth.dart';
import './user_state.dart';

void main() => runApp(
    ChangeNotifierProvider(create: (ctx) => UserState(), child: const MyApp()));

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Czytelnia';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      home: MyStatelessWidget(),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Czytelnia'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Login or register',
              onPressed: () => showDialog<String>(
                  context: context, builder: (BuildContext context) => Auth())),
          IconButton(
            icon: const Icon(Icons.plagiarism),
            tooltip: 'Go to the library',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return BookLib();
              }));
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Go to Your favourite books',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return Favorites();
              }));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Witaj w czytelni',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
