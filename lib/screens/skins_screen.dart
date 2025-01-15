import 'package:flutter/material.dart';

class SkinGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 4, // Replace with actual skin count
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/bg_spring.webp', // Replace with actual skin image
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Skin ${index + 1}'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add skin logic here
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Skin'),
      ),
    );
  }
}
