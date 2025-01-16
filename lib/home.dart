// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:fluttcraft_launcher/ui/navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'cubits/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'constants.dart';

class ImageThemeMenuItem extends StatelessWidget {
  final String imgPath;
  final String name;

  const ImageThemeMenuItem({
    required this.imgPath,
    required this.name,
    super.key,
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
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  switch (index) {
                    case 0:
                      context.go('/home');
                    case 1:
                      context.go('/instances');
                    case 2:
                      context.go('/skins');
                  }
                },
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
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BrightnessButton(),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.image),
                            onSelected: (choice) {
                              // Handle selection based on value
                              switch (choice) {
                                case 'spring':
                                  {
                                    context
                                        .read<SettingsCubit>()
                                        .updateThemeWithImage(
                                            'assets/bg_spring.webp');
                                    break;
                                  }

                                case 'winter':
                                  {
                                    context
                                        .read<SettingsCubit>()
                                        .updateThemeWithImage(
                                            'assets/bg_winter.webp');
                                    break;
                                  }
                                case 'end':
                                  {
                                    context
                                        .read<SettingsCubit>()
                                        .updateThemeWithImage(
                                            'assets/bg_end.webp');
                                    break;
                                  }
                                case 'desert':
                                  {
                                    context
                                        .read<SettingsCubit>()
                                        .updateThemeWithImage(
                                            'assets/bg_desert.webp');
                                    break;
                                  }
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem<String>(
                                  value: 'spring',
                                  child: ImageThemeMenuItem(
                                      imgPath: 'assets/bg_spring.webp',
                                      name: 'Spring'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'winter',
                                  child: ImageThemeMenuItem(
                                      imgPath: 'assets/bg_winter.webp',
                                      name: 'Winter'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'end',
                                  child: ImageThemeMenuItem(
                                      imgPath: 'assets/bg_end.webp',
                                      name: 'End'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'desert',
                                  child: ImageThemeMenuItem(
                                      imgPath: 'assets/bg_desert.webp',
                                      name: 'Desert'),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
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

class _ColorImageButton extends StatelessWidget {
  const _ColorImageButton({
    required this.handleImageSelect,
    required this.imageSelected,
    required this.colorSelectionMethod,
  });

  final void Function(int) handleImageSelect;
  final ColorImageProvider imageSelected;
  final ColorSelectionMethod colorSelectionMethod;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.image_outlined,
      ),
      tooltip: 'Select a color extraction image',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        return List.generate(ColorImageProvider.values.length, (index) {
          final currentImageProvider = ColorImageProvider.values[index];

          return PopupMenuItem(
            value: index,
            enabled: currentImageProvider != imageSelected ||
                colorSelectionMethod != ColorSelectionMethod.image,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 48),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image(
                          image: AssetImage(currentImageProvider.path),
                          fit: BoxFit.cover,
                          height: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentImageProvider.label),
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleImageSelect,
    );
  }
}
