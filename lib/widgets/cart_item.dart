import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  const CartItem(
      {super.key,
      required this.id,
      required this.title,
      required this.quantity,
      required this.price,
      required this.productId});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to remove items from the dialog?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      ),
      onDismissed: (direction) => Provider.of<Cart>(context, listen: false).removeItem(productId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 6,
        ),
        padding: const EdgeInsets.only(right: 12),
        alignment: Alignment.centerRight,
        color: Theme.of(context).colorScheme.error,
        child: FittedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
              Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              )
            ],
          ),
        ),
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: Chip(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              label: Padding(
                padding: const EdgeInsets.all(1),
                child: FittedBox(
                  child: Text(
                    '\$$price',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                  ),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total \$${(price * quantity).toStringAsFixed(2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
