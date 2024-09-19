import 'package:flutter/material.dart';

class tempHomePage extends StatelessWidget {
  const tempHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('title'),),
      body: Container(
        child: Text('Container'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.pushNamed(context, "/detail");
      },
      child: Icon(Icons.inbox),
      ),
      );
  }
}