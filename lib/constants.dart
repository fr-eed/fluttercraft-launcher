// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

// NavigationRail shows if the screen width is greater or equal to
// narrowScreenWidthThreshold; otherwise, NavigationBar is used for navigation.
const double narrowScreenWidthThreshold = 450;

const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;

const double transitionLength = 500;

const smallSpacing = 10.0;
const double widthConstraint = 450;

const minWindowSize = Size(1100, 600);

// Whether the user has chosen a theme color via a direct [ColorSeed] selection,
// or an image [ColorImageProvider].
enum ColorSelectionMethod {
  colorSeed,
  image,
}

enum ColorSeed {
  baseColor('M3 Baseline', Color(0xff6750a4));

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ImageThene {
  spring('Spring', "assets/bg_spring.webp"),
  winter('Winter', "assets/bg_winter.webp"),
  sakura('Sakura', "assets/bg_sakura.webp"),
  desert('Desert', "assets/bg_desert.webp");

  const ImageThene(this.label, this.path);
  final String label;
  final String path;
}

enum ScreenSelected {
  play(0),
  instances(1),
  settings(2);

  const ScreenSelected(this.value);
  final int value;
}

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    key: Key("play"),
    tooltip: '',
    icon: Icon(Icons.videogame_asset_outlined),
    label: 'Play',
    selectedIcon: Icon(Icons.videogame_asset),
  ),
  NavigationDestination(
    key: Key("instances"),
    tooltip: 'Instances',
    icon: Icon(Icons.widgets_outlined),
    label: 'Instances',
    selectedIcon: Icon(Icons.widgets),
  ),
  NavigationDestination(
    key: Key("settings"),
    tooltip: '',
    icon: Icon(Icons.settings_outlined),
    label: 'Settings',
    selectedIcon: Icon(Icons.settings),
  ),
];
