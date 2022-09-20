import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String title;
  final String id;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFav() async {
    final oldStatus = isFavorite;
    final url = Uri.https(
        'shop-app-d0b16-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json');
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.patch(
        url,
        body: jsonEncode(
          {
            'isFavorite': isFavorite,
          },
        ),
      );
      if(response.statusCode >= 400){
        throw const HttpException('Unable to update status');
      }
    } catch (e) {
      isFavorite = oldStatus;
      notifyListeners();
      rethrow;
    }
  }
}
