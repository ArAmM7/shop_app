import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0.8),
          leading: IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () async {
              try {
                await product.toggleFav(authData.token, authData.userId);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(milliseconds: 3600),
                  content: Text('An error occurred $e'),
                  action: null,
                ));
              }
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Item added to cart'),
                  duration: const Duration(milliseconds: 3600),
                  action: SnackBarAction(
                    onPressed: () => cart.removeSingleItem(product.id),
                    label: 'Undo',
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
          child: Hero(
            createRectTween: (begin, end) => MaterialRectCenterArcTween(begin: begin, end: end),
            transitionOnUserGestures: true,
            tag: product.id,
            child: FadeInImage(
              fadeInDuration: const Duration(milliseconds: 160),
              fit: BoxFit.contain,
              placeholder: const AssetImage('assets/images/Loading_icon.gif'),
              image: NetworkImage(
                product.imageUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
