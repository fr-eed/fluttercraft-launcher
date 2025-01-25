// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'cubits/settings_cubit.dart';

class Home extends StatefulWidget {
  final Widget child;
  final int index;

  const Home({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
  }

  void _handleNavigation(int index) {
    setState(() => _selectedIndex = index);
    _navigateToRoute(index);
  }

  void _navigateToRoute(int index) {
    final routes = {
      0: '/home',
      1: '/instances',
      2: '/skins',
      3: '/auth',
      4: '/settings',
    };

    final route = routes[index];
    if (route != null) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Row(
            children: [
              NavigationRail(
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: _handleNavigation,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.videogame_asset),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.widgets_outlined),
                    label: Text('Instances'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.format_paint),
                    label: Text('Skins'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_circle),
                    label: Text('Account'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                trailing: NavigationTrailing(),
              ),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

class NavigationTrailing extends StatelessWidget {
  NavigationTrailing({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BrightnessButton(),
              _ThemeSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    this.showTooltipBelow = true,
  });

  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Tooltip(
          preferBelow: showTooltipBelow,
          message: 'Toggle brightness',
          child: IconButton(
            // dark = dark icon because inconsistency with auto brightness
            icon: state.brightnessMode == BrightnessMode.dark
                ? const Icon(Icons.dark_mode_outlined)
                : state.brightnessMode == BrightnessMode.light
                    ? const Icon(Icons.light_mode_outlined)
                    : const Icon(Icons.brightness_auto_outlined),
            onPressed: () =>
                context.read<SettingsCubit>().cycleBrightnessModes(),
          ),
        );
      },
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.image),
      onSelected: (choice) => _handleThemeSelection(context, choice),
      itemBuilder: _buildThemeItems,
    );
  }

  void _handleThemeSelection(BuildContext context, String choice) {
    final themes = {
      'spring': 'assets/bg_spring.webp',
      'winter': 'assets/bg_winter.webp',
      'end': 'assets/bg_end.webp',
      'desert': 'assets/bg_desert.webp',
    };

    final theme = themes[choice];
    if (theme != null) {
      context.read<SettingsCubit>().updateThemeWithImage(theme);
    }
  }

  List<PopupMenuEntry<String>> _buildThemeItems(BuildContext context) {
    final themes = [
      ('spring', 'Spring'),
      ('winter', 'Winter'),
      ('end', 'End'),
      ('desert', 'Desert'),
    ];

    return themes
        .map((theme) => PopupMenuItem<String>(
              value: theme.$1,
              child: ImageThemeMenuItem(
                imgPath: 'assets/bg_${theme.$1}.webp',
                name: theme.$2,
              ),
            ))
        .toList();
  }
}

class ImageThemeMenuItem extends StatelessWidget {
  final String imgPath;
  final String name;

  const ImageThemeMenuItem({
    super.key,
    required this.imgPath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imgPath,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(name),
      ],
    );
  }
}
