// lib/screens/cart_page.dart
import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: const Color(0xFFFF9E17),
      ),
      body: const Center(
        child: Text('Your cart is empty.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
