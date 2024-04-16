import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import '../models/providers/cart.dart';
import '../models/providers/orders.dart';
import '../widgets/cart_card.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: (cart.totalAmount <= 0)
                        ? null
                        : () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Placing order...'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            await Provider.of<Orders>(context, listen: false)
                                .addOrder(cart.items.values.toList(),
                                    cart.totalAmount);
                            cart.clear();
                          },
                    child: Text('ORDER NOW'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Text('Your cart is empty.'),
                  )
                : ListView.builder(
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return CartCard(
                        id: cartItem.id,
                        price: cartItem.price,
                        quantity: cartItem.quantity,
                        title: cartItem.title,
                        productId: cart.items.keys.toList()[i],
                      );
                    },
                    itemCount: cart.items.length,
                  ),
          ),
        ],
      ),
    );
  }
}
