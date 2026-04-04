import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  final String? orderId;
  const OrderScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: Center(
        child: Text(
          orderId != null ? 'Order ID: $orderId' : 'No Order ID provided',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
