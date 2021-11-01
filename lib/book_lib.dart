import 'package:flutter/material.dart';

class BookLib extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteka książek'),
      ),
      body: const Center(
        child: Text(
          'Wyszukaj książki',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}