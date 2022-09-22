import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../.secrets/secrets.dart' as secrets; // file where sensitive information is stored
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String title;
  final String id;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  final _domain = secrets.domainDatabase;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFav(String authToken, String userId) async {
    final oldStatus = isFavorite;
    final url = Uri.https(_domain, '/userFavorites/$userId/$id.json', {'auth': authToken});
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: jsonEncode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        throw const HttpException('Unable to update status');
      }
    } catch (e) {
      isFavorite = oldStatus;
      notifyListeners();
      rethrow;
    }
  }
}
