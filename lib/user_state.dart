import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  /// Internal, private state of the cart.
  //final List<Item> _items = [];
  bool loggedIn = false;
  int userID = 0;
  String token = "";

  void logIn(int userID, String token) {
    loggedIn = true;
    this.userID = userID;
    this.token = token;
    notifyListeners();
  }

  void logOut() {
    loggedIn = false;
    userID = 0;
    token = "";
    notifyListeners();
  }

  /// An unmodifiable view of the items in the cart.
  // UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  // /// The current total price of all items (assuming all items cost $42).
  // int get totalPrice => _items.length * 42;

  // /// Adds [item] to cart. This and [removeAll] are the only ways to modify the
  // /// cart from the outside.
  // void add(Item item) {
  //   _items.add(item);
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }

  // /// Removes all items from the cart.
  // void removeAll() {
  //   _items.clear();
  //   // This call tells the widgets that are listening to this model to rebuild.
  //   notifyListeners();
  // }
}
