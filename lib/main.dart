import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/providers/products_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => Cart()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          fontFamily: 'Lato',
          colorScheme: const ColorScheme(
              primary: Colors.purple,
              onPrimary: Colors.white,
              secondary: Colors.deepOrange,
              onSecondary: Colors.white,
              brightness: Brightness.light,
              background: Colors.white70,
              onBackground: Colors.black,
              error: Colors.red,
              onError: Colors.white,
              surface: Colors.white70,
              onSurface: Colors.black),
        ),
        home: const ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
        },
      ),
    );
  }
}
