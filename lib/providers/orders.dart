import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../.secrets/secrets.dart' as secrets; // file where sensitive information is stored
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  const OrderItem(
      {required this.id, required this.amount, required this.products, required this.dateTime});
}

class Orders with ChangeNotifier {
  late final _url = Uri.https(secrets.domainDatabase, '/orders/$userId.json', {'auth': authToken});

  final String authToken;
  final String userId;

  List<OrderItem> _orders;

  Orders(this.userId, this.authToken, this._orders);

  List<OrderItem> get orders {
    return _orders;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timestamp = DateTime.now();
    try {
      final response = await http.post(
        _url,
        body: jsonEncode(
          {
            'amount': total,
            'products': cartProducts
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price,
                    })
                .toList(),
            'dateTime': timestamp.toIso8601String(),
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final response = await http.get(_url);
      if (response.body.toLowerCase() == 'null') {
        return;
      }
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach(
        (key, value) {
          loadedOrders.add(
            OrderItem(
              id: key,
              amount: value['amount'].toDouble(),
              dateTime: DateTime.parse(value['dateTime']),
              products: (value['products'] as List<dynamic>)
                  .map(
                    (e) => CartItem(
                      id: e['id'],
                      title: e['title'],
                      quantity: e['quantity'].toInt(),
                      price: e['price'].toDouble(),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
