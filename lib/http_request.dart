import 'package:flutter/material.dart';
import 'dart:convert';

void httpRequest(void loading(state), Function fetch, void handleResponse(code, response), void showError(message)) async{
  loading(true);
  var response;
  try {
    response = await fetch().timeout(const Duration(seconds: 2));
  } catch (e) {
    loading(false);
    showError("Nie udało się połączyć z serwerem!");
    return;
  }

  final code = response.statusCode;
    if (code >= 200 && code < 300) {
      handleResponse(code, response.body);
    }
    else{
      try{
        showError(jsonDecode(response.body['detail']));
      }
      catch(e){
        showError("Coś poszło nie tak po stronie serwera");
      }
    }
    loading(false);
}