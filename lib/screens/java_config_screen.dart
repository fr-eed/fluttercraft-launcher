import 'package:flutter/material.dart';

class JavaConfigScreen extends StatefulWidget {
  @override
  _JavaConfigScreenState createState() => _JavaConfigScreenState();
}

class _JavaConfigScreenState extends State<JavaConfigScreen> {
  double _ramAllocation = 2.0; // GB
  String _selectedJavaVersion = '17';
  bool _useCustomJavaArgs = false;
  TextEditingController _javaArgsController = TextEditingController();

  final List<String> _availableJavaVersions = ['8', '11', '17', '19'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Java Configuration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RAM Allocation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _ramAllocation,
              min: 1.0,
              max: 32.0,
              divisions: 31,
              label: '${_ramAllocation.toStringAsFixed(1)} GB',
              onChanged: (value) {
                setState(() {
                  _ramAllocation = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Java Version',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedJavaVersion,
              isExpanded: true,
              items: _availableJavaVersions.map((String version) {
                return DropdownMenuItem<String>(
                  value: version,
                  child: Text('Java $version'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedJavaVersion = newValue;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _useCustomJavaArgs,
                  onChanged: (bool? value) {
                    setState(() {
                      _useCustomJavaArgs = value ?? false;
                    });
                  },
                ),
                Text('Use Custom Java Arguments'),
              ],
            ),
            if (_useCustomJavaArgs)
              TextField(
                controller: _javaArgsController,
                decoration: InputDecoration(
                  hintText: '-XX:+UseConcMarkSweepGC -Xmx4G',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save configuration
                  Navigator.pop(context);
                },
                child: Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
