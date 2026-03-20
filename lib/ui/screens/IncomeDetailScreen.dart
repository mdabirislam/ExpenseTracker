import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('This page is under construction', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}