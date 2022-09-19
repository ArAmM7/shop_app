import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'order #${widget.order.id}',
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(
                  '\$${widget.order.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
            subtitle: Text(
              DateFormat('dd MM yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
                onPressed: () => setState(() {
                      _expanded = !_expanded;
                    }),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
          ),
          if (_expanded)
            Container(
              margin: const EdgeInsets.all(12),
              height: min(widget.order.products.length * 24 + 20, 180),
              child: ListView.builder(
                  itemBuilder: (context, index) => Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.order.products[index].title,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          Text(
                            '${widget.order.products[index].quantity} x \$${widget.order.products[index].price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.caption,
                          )
                        ],
                      ),
                  itemCount: widget.order.products.length),
            ),
        ],
      ),
    );
  }
}
