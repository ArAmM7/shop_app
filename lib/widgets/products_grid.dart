import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/providers/products_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavoritesOnly;

  const ProductsGrid(this.showFavoritesOnly, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final products =
        showFavoritesOnly ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        crossAxisCount: 2,
        childAspectRatio: 5 / 4,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: const ProductItem(),
      ),
    );
  }
}