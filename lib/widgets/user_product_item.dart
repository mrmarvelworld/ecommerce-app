import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/edit_product_screen.dart';
import '../models/providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffoldmessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(children: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: Icon(Icons.edit),
              color: Colors.blueGrey),
          IconButton(
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .deleteProduct(id);
                  scaffoldmessenger.showSnackBar(SnackBar(
                    content: Text('Successfully deleted!'),
                    duration: Duration(seconds: 2),
                  ));
                } catch (error) {
                  scaffoldmessenger.showSnackBar(SnackBar(
                    content: Text('Deleting failed!'),
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              icon: Icon(Icons.delete),
              color: Colors.red),
        ]),
      ),
    );
  }
}
