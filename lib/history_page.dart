import 'dart:io';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<File>? capturedImages;  // Notice the question mark, making it nullable

  HistoryPage({this.capturedImages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
      ),
      body: ListView.builder(
        itemCount: capturedImages?.length ?? 0,  // Null-aware
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              capturedImages![index],  // Using ! to assert that it's non-null at this point
              height: 300,
              width: 300,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
