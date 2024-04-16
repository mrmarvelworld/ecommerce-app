import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

class Products with ChangeNotifier {
  final String authToken;
  List<Product> _items = [];
  final String userId;
  Products(this.authToken, this._items, this.userId);

  var _showFavoritesOnly = false;
  List<Product> get items {
    if (_showFavoritesOnly) {
      return _items.where((productItem) => productItem.isFavorite).toList();
    }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }

  List<Product> get favoriteItems {
    return _items.where((productItem) => productItem.isFavorite).toList();
  }

  //firebase methods

  Future<void> addProduct(Product product) async {
    final _productPath = Uri.https(
        'flutter-update-2eab0-default-rtdb.firebaseio.com', '/products.json', {
      'auth': authToken,
    });
    try {
      final response = await http.post(_productPath,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final _productPath = filterByUser
        ? Uri.parse(
            'https://flutter-update-2eab0-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"')
        : Uri.https('flutter-update-2eab0-default-rtdb.firebaseio.com',
            '/products.json', {'auth': authToken});

    try {
      final response = await http.get(_productPath);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final favUrl = Uri.https(
          'flutter-update-2eab0-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json',
          {'auth': authToken});
      final favoriteStatusResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteStatusResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
    } catch (error) {
      throw (error);
    }
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final _productPath = Uri.https(
          'flutter-update-2eab0-default-rtdb.firebaseio.com',
          '/products/$id.json',
          {'auth': authToken});
      await http.patch(_productPath,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final _productPath = Uri.https(
        'flutter-update-2eab0-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': authToken});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(_productPath);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    } else {}
    // existingProduct = null;
  }
}
