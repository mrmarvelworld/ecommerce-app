import 'package:flutter/material.dart';
import 'package:shop_app/helpers/custom_routes.dart';
import 'package:shop_app/models/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_product_screen.dart';
import '/screens/cart_screen.dart';
import '/screens/product_detail_screen.dart';
import '/screens/product_overview_screen.dart';
import 'package:provider/provider.dart';

import '/models/providers/cart.dart';
import '/models/providers/products.dart';
import '/models/providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (
              context,
            ) =>
                Products('', [], ''),
            update: (context, auth, previousProducts) {
              // Update logic based on changes in Auth
              return Products(
                  auth.token,
                  previousProducts == null ? [] : previousProducts.items,
                  auth.userId);
            },
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (
              context,
            ) =>
                Orders('', [], ''),
            update: (context, auth, previousOrders) {
              // Update logic based on changes in Auth
              return Orders(
                auth.token,
                previousOrders == null ? [] : previousOrders.orders,
                auth.userId,
              );
            },
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primaryColor: Colors.deepOrange,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
            ),
            debugShowCheckedModeBanner: false,
            home: auth.isAuth
                ? ProductOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapShot) =>
                        authResultSnapShot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              ProductOverviewScreen.routeName: (context) =>
                  ProductOverviewScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductScreen.routeName: (context) => UserProductScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
