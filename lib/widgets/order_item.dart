import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  const OrderItem(this.order);

  final ord.OrderItem order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          ListTile(
            title: Text('\$ ${widget.order.amount}'),
            subtitle: Text(
                DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
            height: _expanded
                ? min(widget.order.products.length * 20.0 + 10, 180)
                : 0,
            child: ListView.builder(
              itemBuilder: (ctx, i) =>
                  ExpandedOrderItem(widget.order.products.toList()[i]),
              itemCount: widget.order.products.length,
            ),
          )
        ]),
      ),
    );
  }
}

Widget ExpandedOrderItem(product) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        product.title,
        style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
      ),
      Text(
        '${product.quantity} X \$${product.price} ',
        style: TextStyle(fontSize: 12.5, color: Colors.grey),
      )
    ],
  );
}
