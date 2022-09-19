import 'package:flutter/material.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import '../screens/orders_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
              title: const Text('Welcome to My Shop'),
              automaticallyImplyLeading: false),
          const Divider(),
          buildListTile(
            'Shop',
            Icons.shop,
            () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const Divider(),
          buildListTile(
            'Orders',
            Icons.shopping_cart_checkout,
            () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
          ),
          const Divider(),
          buildListTile(
            'User Products',
            Icons.edit_note,
            () => Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(String title, IconData icon, Function tabHandler) {
    return ListTile(
      onTap: () => tabHandler(),
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}