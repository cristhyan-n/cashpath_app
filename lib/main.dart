import 'package:flutter/material.dart';

void main() {
  runApp(const CashPathApp());
}

class CashPathApp extends StatelessWidget {
  const CashPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CashPath',
      home: Scaffold(body: Center(child: Text('CashPath'))),
    );
  }
}
