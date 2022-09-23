import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../.secrets/secrets.dart' as secrets; // file where sensitive information is stored
import '../models/http_exception.dart';
import '../providers/product.dart';

class ProductsProvider with ChangeNotifier {
  final _domain = secrets.domainDatabase;
  final String authToken;
  final String userId;

  ProductsProvider(this.userId, this.authToken, this._items);

  List<Product> _items;

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
      final url = Uri.https(
        _domain,
        '/products.json',
        {'auth': authToken},
      );
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
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
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(_domain, '/products/$id.json', {'auth': authToken});
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
      } catch (e) {
        rethrow;
      } finally {
        notifyListeners();
      }
    }
  }

  Future<void> removeProduct(String id) async {
    final url = Uri.https(_domain, '/products/$id.json', {'auth': authToken});
    final existingProductIndex = _items.indexWhere((element) => element.id == id);
    try {
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete Product. because ${response.body}');
      }
      _items.removeAt(existingProductIndex);
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final queryParameters = filterByUser
        ? {'auth': authToken, 'orderBy': '"creatorId"', 'equalTo': '"$userId"'}
        : {'auth': authToken};
    final url = Uri.https(
      _domain,
      '/products.json',
      queryParameters,
    );

    try {
      final response = await http.get(url);
      if (response.body.toString().toLowerCase().contains('null')) {
        return;
      }
      final extractedData = jsonDecode(response.body); //as Map<String, dynamic>;
      final urlFav = Uri.https(_domain, '/userFavorites/$userId.json', {'auth': authToken});
      final responseFav = await http.get(urlFav);
      final favoriteData = jsonDecode(responseFav.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
            id: key.toString(),
            title: value['title'].toString(),
            description: value['description'].toString(),
            price: value['price'].toDouble(),
            imageUrl: value['imageUrl'].toString(),
            isFavorite: responseFav.body.toLowerCase() == 'null'
                ? false
                : favoriteData[key.toString()] ?? false));
      });
      _items = loadedProducts;
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
