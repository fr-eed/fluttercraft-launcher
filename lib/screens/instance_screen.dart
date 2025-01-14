import 'package:flutter/material.dart';

class InstancesScreen extends StatelessWidget {
  // Dummy data
  final List<Map<String, String>> instances = [
    {
      'name': 'Survival World 1.20.1',
      'version': '1.20.1',
      'lastPlayed': '2 hours ago',
      'type': 'Vanilla'
    },
    {
      'name': 'Forge Modpack',
      'version': '1.19.2',
      'lastPlayed': '1 day ago',
      'type': 'Forge'
    },
    {
      'name': 'Creative Building',
      'version': '1.20.1',
      'lastPlayed': '3 days ago',
      'type': 'Vanilla'
    },
    {
      'name': 'Fabric Modded',
      'version': '1.19.4',
      'lastPlayed': '1 week ago',
      'type': 'Fabric'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final instance = instances[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.games),
              title: Text(instance['name']!),
              subtitle: Text('${instance['version']!} - ${instance['type']}'),
              trailing: Text(instance['lastPlayed']!),
              onTap: () {
                // Handle instance selection
              },
            ),
          );
        },
      ),
    );
  }
}
