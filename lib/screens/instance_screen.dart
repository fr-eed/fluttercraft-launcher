import 'package:flutter/material.dart';

class InstancesScreen extends StatefulWidget {
  InstancesScreen({super.key});

  // Dummy data
  final List<Map<String, String>> instances = [
    {
      'name': 'Survival World 1.20.1',
      'version': '1.20.1',
      'lastPlayed': '2 hours ago',
      'type': 'Vanilla',
    },
    {
      'name': 'Forge Modpack',
      'version': '1.19.2',
      'lastPlayed': '1 day ago',
      'type': 'Forge',
    },
    {
      'name': 'Creative Building',
      'version': '1.20.1',
      'lastPlayed': '3 days ago',
      'type': 'Vanilla',
    },
    {
      'name': 'Fabric Modded',
      'version': '1.19.4',
      'lastPlayed': '1 week ago',
      'type': 'Fabric',
    },
  ];

  @override
  State<InstancesScreen> createState() => _InstancesScreenState();
}

class _InstancesScreenState extends State<InstancesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle create instance
        },
        label: const Text('Create Instance'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: widget.instances.length,
        itemBuilder: (context, index) {
          final instance = widget.instances[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.games),
              title: Text(instance['name']!),
              subtitle: Text('${instance['version']!} - ${instance['type']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(instance['lastPlayed']!),
                  SizedBox(width: 12),
                  Builder(
                    builder: (context) => ElevatedButton.icon(
                      onPressed: () {
                        // Handle edit instance
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                      ),
                      icon: const Icon(Icons.edit),
                      label: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
