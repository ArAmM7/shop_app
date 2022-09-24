import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/products_provider.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/orders_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/user_products_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, ProductsProvider>(
              create: (context) => ProductsProvider('', '', []),
              update: (context, auth, prev) => ProductsProvider(
                    auth.userId,
                    auth.token,
                    prev?.items == null ? [] : prev!.items,
                  )),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (context) => Orders('', '', []),
              update: (context, auth, prev) => Orders(
                    auth.userId,
                    auth.token,
                    prev?.orders == null ? [] : prev!.orders,
                  )),
          ChangeNotifierProvider(create: (context) => Cart()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            theme: ThemeData(
                brightness: Brightness.light,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuilder(),
                  TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  TargetPlatform.windows: CustomPageTransitionBuilder(),
                }),
                colorScheme: const ColorScheme(
                    brightness: Brightness.light,
                    primary: Colors.purple,
                    onPrimary: Colors.white,
                    secondary: Color.fromRGBO(0, 127, 0, 1),
                    onSecondary: Colors.white,
                    background: Colors.white70,
                    onBackground: Colors.grey,
                    error: Colors.red,
                    onError: Colors.white,
                    surface: Colors.white70,
                    onSurface: Colors.black)),
            home: auth.isAuth
                ? const ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
                        ? const SplashScreen()
                        : const AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
              CartScreen.routeName: (ctx) => const CartScreen(),
              OrdersScreen.routeName: (ctx) => const OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => const EditProductScreen(),
            },
          ),
        ));
  }
}
