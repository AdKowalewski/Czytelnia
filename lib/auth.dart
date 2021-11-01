import 'package:flutter/material.dart';

class Auth extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zaloguj się lub zarejstruj!'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children : <Widget>[
        OutlinedButton(
          // style: ButtonStyle(
          //   shape: MaterialStateProperty.all(
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)
          //     )
          //   )
          // ),
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Zarejstruj się'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('Zaloguj się'),
        ),
      ])
    );
  }
}