import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/products_grid.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/widgets/badge.dart';

enum _FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              color: Theme.of(context).colorScheme.secondary,
              value: cartData.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          ),
          PopupMenuButton(
            onSelected: (selectedValue) {
              setState(() {
                if (selectedValue == _FilterOptions.favorites) {
                  _showFavOnly = true;
                } else {
                  _showFavOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _FilterOptions.favorites,
                child: Text('Only Favorites'),
              ),
              const PopupMenuItem(
                value: _FilterOptions.all,
                child: Text('Show All'),
              )
            ],
          ),
        ],
      ),
      body: ProductsGrid(_showFavOnly),
    );
  }
}
