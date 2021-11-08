import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import './user_state.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Dokonaj autoryzacji'),
        content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Consumer<UserState>(builder: (context, state, child) {
                if (!state.loggedIn) {
                  return OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Zarejstruj się'),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => const LoginForm());
                },
                child: const Text('Zaloguj się'),
              ),
            ]));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String username = "";
  String password = "";

  //Przenieść do gloabalnego stanu aplikacji

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return AlertDialog(
      title: const Text('Logowanie'),
      content: Form(
        key: _formKey,
        child: Wrap(
          children: <Widget>[
            const Text("Login"),
            TextFormField(
              onChanged: (text) {
                username = text;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź login';
                }
                return null;
              },
            ),
            const SizedBox(height: 100),
            const Text("Hasło"),
            TextFormField(
              onChanged: (text) {
                password = text;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wprowadź hasło';
                }
                return null;
              },
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () async {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Przetwarzanie')));

                  bool valid = await getToken();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (valid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zalogowano pomyślnie')),
                    );
                    Navigator.pop(context, 'OK');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logowanie nieudane')),
                    );
                  }
                }
              },
              child: const Center(child: Text('Wyślij')),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> getToken() async {
    // Wczytywanie z pliku
    // String json = await rootBundle.loadString('token.json');
    // token = JSON.jsonDecode(json)['token'];
    // userID = JSON.jsonDecode(json)['id'];
    // userName = JSON.jsonDecode(json)['username'];
    // debugPrint(token);
    // return true;

    //Właściwe wczytywanie z serwera
    final response = await http.post(
        Uri.parse('http://localhost:8000/api/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.jsonEncode(
            <String, String>{'username': username, 'password': password}));
    if (response.statusCode == 200) {
      String token = JSON.jsonDecode(response.body)['token'];
      Provider.of<UserState>(context, listen: false).logIn(123, token);
      debugPrint(token);
      return true;
    } else {
      return false;
    }
  }
}
