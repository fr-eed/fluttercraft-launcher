import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttercraft_launcher/cubits/settings_cubit.dart';
import 'package:fluttercraft_launcher/ui/outline_list_tile.dart';
import 'package:fluttercraft_launcher/ui/theme_brightness_toggle.dart';
import '../ui/outline_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.0,
        children: [
          OutlineListTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Select your preferred language',
            child: DropdownButton<String>(
              value: 'English',
              items: ['English', 'Spanish', 'French'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {},
            ),
          ),
          OutlineListTile(
            icon: Icons.brightness_4,
            title: 'Theme',
            subtitle: 'Toggle between light and dark mode',
            child: BrightnessButton(),
          ),
        ],
      ),
    );
  }
}
