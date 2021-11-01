import 'package:flutter/material.dart';

class Favorites extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulbione książki'),
      ),
      body: const Center(
        child: Text(
          'Ulubione książki',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}