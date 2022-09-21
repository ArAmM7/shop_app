import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../providers/product.dart';

class ProductsProvider with ChangeNotifier {
  final _url = Uri.https(
      'shop-app-d0b16-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json');

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(
        _url,
        body: jsonEncode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );

      final newProduct = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'shop-app-d0b16-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/$id.json');
      try {
        final response = await http.patch(
          url,
          body: jsonEncode(
            {
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price.toDouble(),
              'imageUrl': newProduct.imageUrl,
            },
          ),
        );
        if (response.statusCode >= 400) {
          throw const HttpException('Unable to update status');
        }
        _items[prodIndex] = newProduct;
        notifyListeners();
      } catch (e) {
        rethrow;
      } finally {}
    }
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.https(
        'shop-app-d0b16-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException(
            'Could not delete Product. because ${response.body}');
      }
      _items.removeAt(existingProductIndex);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final response = await http.get(_url);
      if (response.body.toLowerCase() == 'null') {
        return;
      }
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'].toDouble(),
            imageUrl: value['imageUrl'],
            isFavorite: value['isFavorite']));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
