import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shop_app/models/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;
  Orders(this.authToken, this._orders, this.userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  int get totalOrders {
    return _orders.length;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final date = DateTime.now();

    final urlPath = Uri.https(
        'flutter-update-2eab0-default-rtdb.firebaseio.com',
        '/orders/$userId.json',
        {'auth': authToken});

    try {
      final response = await http.post(urlPath,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cartProduct) => {
                      'id': cartProduct.id,
                      'title': cartProduct.title,
                      'quantity': cartProduct.quantity,
                      'price': cartProduct.price,
                    })
                .toList(),
            'dateTime': date.toIso8601String(),
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: date,
        ),
      );
    } catch (error) {}

    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final urlPath = Uri.https(
        'flutter-update-2eab0-default-rtdb.firebaseio.com',
        '/orders/$userId.json',
        {'auth': authToken});
    final response = await http.get(urlPath);
    print(json.decode(response.body));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(
            orderData['dateTime'],
          ),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
