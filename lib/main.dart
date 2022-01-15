/// Flutter code sample for AppBar
// This sample shows an [AppBar] with two simple actions. The first action
// opens a [SnackBar], while the second action navigates to a new page.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './favorites.dart';
import './book_lib.dart';
import './auth.dart';
import './user_state.dart';
import './pdf_view.dart';

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
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(builder: (context, state, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Czytelnia'),
          actions: <Widget>[
            // IconButton(
            //   icon: const Icon(Icons.plagiarism),
            //   tooltip: 'Test pdf',
            //   onPressed: () {
            //     Navigator.push(context,
            //         MaterialPageRoute<void>(builder: (BuildContext context) {
            //       return PDFView(1);
            //     }));
            //   },
            // ),
            IconButton(
                icon: const Icon(Icons.login),
                tooltip: 'Logowanie',
                onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Auth())),
            IconButton(
              icon: const Icon(Icons.plagiarism),
              tooltip: 'Biblioteka książek',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return BookLib();
                }));
              },
            ),
            state.loggedIn
                ? IconButton(
                    icon: const Icon(Icons.favorite_border),
                    tooltip: 'Ulubione',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                        return Favorites();
                      }));
                    },
                  )
                : const SizedBox.shrink(),
          ],
        ),
        body: const Center(
          child: Text(
            'Witaj w czytelni',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    });
  }
}
