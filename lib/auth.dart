import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as json;
import 'package:provider/provider.dart';
import './user_state.dart';

class Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Dokonaj autoryzacji'),
        content: Consumer<UserState>(builder: (context, state, child) {
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                !state.loggedIn
                    ? OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'register'),
                        child: const Text('Zarejstruj się'),
                      )
                    : const SizedBox.shrink(),
                !state.loggedIn
                    ? OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, 'login');
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                                  const LoginForm());
                        },
                        child: const Text('Zaloguj się'),
                      )
                    : const SizedBox.shrink(),
                state.loggedIn
                    ? OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context, 'logout');
                          state.logOut();
                        },
                        child: const Text('Wyloguj się'),
                      )
                    : const SizedBox.shrink(),
              ]);
        }));
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

  bool _loading = false;
  String _error = "";

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
            const SizedBox(height: 50),
            ElevatedButton(
                onPressed: () async {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    getToken();
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Przetwarzanie')));

                    // ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // if (valid) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text('Zalogowano pomyślnie')),
                    //   );
                    //   Navigator.pop(context, 'OK');
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(content: Text(_error)),
                    //   );
                    // }
                  }
                },
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Wysyłanie"),
                            SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                                backgroundColor: Colors.blue,
                                strokeWidth: 3,
                              ),
                            )
                          ],
                        ),
                      )
                    : const Text("Wyślij")),
            //const SizedBox(height: 50),
            _error.isNotEmpty
                ? const Divider(color: Colors.grey, thickness: 1.5)
                : const SizedBox.shrink(),
            _error.isNotEmpty ? Text(_error) : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void getToken() async {
    setState(() {
      _loading = true;
      _error = "";
    });
    var response;
    try {
      response = await http
          .post(Uri.parse('http://10.0.2.2:8000/api/users/login'),
              body: json.jsonEncode(
                  <String, String>{'username': username, 'password': password}))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Nie udało się połączyć z serwerem";
      });
      return;
    }

    if (response.statusCode == 200) {
      String token = json.jsonDecode(response.body)['token'];
      int id = json.jsonDecode(response.body)['id'];
      Provider.of<UserState>(context, listen: false).logIn(id, token);
      debugPrint(token);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zalogowano pomyślnie')),
      );
      Navigator.pop(context, 'OK');
    } else {
      setState(() {
        _error = json.jsonDecode(response.body)['details'];
      });
    }
    setState(() {
      _loading = false;
    });
  }
}
