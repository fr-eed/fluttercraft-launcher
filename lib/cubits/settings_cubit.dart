import "package:fluttcraft_launcher/constants.dart";
import "package:flutter/material.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState()) {
    _init();
  }

  void _init() {
    // init theme
    // TODO use theme color manager
    updateThemeWithImage(state.selectedImagePath);
  }

  void cycleBrightnessModes() {
    switch (state.brightnessMode) {
      case BrightnessMode.light:
        setThemeBrightnessMode(BrightnessMode.dark);
      case BrightnessMode.dark:
        setThemeBrightnessMode(BrightnessMode.system);
      case BrightnessMode.system:
        setThemeBrightnessMode(BrightnessMode.light);
    }
  }

  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  void setThemeBrightnessMode(BrightnessMode brightnessMode) {
    emit(state.copyWith(
      brightnessMode: brightnessMode,
    ));
  }

  void toggleNotifications(bool enabled) {
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateThemeWithImage(String imagePath) async {
    final colorSchemeLight = await ColorScheme.fromImageProvider(
      brightness: Brightness.light,
      provider: AssetImage(imagePath),
    );

    final colorSchemeDark = await ColorScheme.fromImageProvider(
      brightness: Brightness.dark,
      provider: AssetImage(imagePath),
    );

    emit(state.copyWith(
      themeColorSchemeLight: colorSchemeLight,
      themeColorSchemeDark: colorSchemeDark,
      selectedImagePath: imagePath,
    ));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState(
      brightnessMode: BrightnessMode.values
          .byName(json['brightnessMode'] as String? ?? 'system'),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      selectedImagePath: json['selectedImagePath'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'brightnessMode': state.brightnessMode.name,
      'fontSize': state.fontSize,
      'notificationsEnabled': state.notificationsEnabled,
      'selectedImagePath': state.selectedImagePath,
    };
  }
}

enum BrightnessMode { system, light, dark }

class ThemeManager {
  final SettingsState state;
  final BuildContext context;

  ThemeManager(this.state, this.context);

  Brightness get themeBrightness {
    switch (state.brightnessMode) {
      case BrightnessMode.system:
        return View.of(context).platformDispatcher.platformBrightness;
      case BrightnessMode.light:
        return Brightness.light;
      case BrightnessMode.dark:
        return Brightness.dark;
    }
  }

  ColorScheme get themeColorScheme {
    return (themeBrightness == Brightness.light
            ? state.themeColorSchemeLight
            : state.themeColorSchemeDark) ??
        ColorScheme.fromSeed(
          // fallback
          brightness: themeBrightness,
          seedColor: Colors.blue,
        );
  }
}

class SettingsState {
  final BrightnessMode brightnessMode;
  final double fontSize;
  final bool notificationsEnabled;
  final String selectedImagePath;
  final ColorScheme? themeColorSchemeLight;
  final ColorScheme? themeColorSchemeDark;

  const SettingsState({
    this.brightnessMode = BrightnessMode.system,
    this.fontSize = 14.0,
    this.notificationsEnabled = true,
    this.selectedImagePath = "assets/bg_sakura.webp",
    this.themeColorSchemeLight,
    this.themeColorSchemeDark,
  });

  SettingsState copyWith({
    BrightnessMode? brightnessMode,
    double? fontSize,
    bool? notificationsEnabled,
    String? selectedImagePath,
    ColorScheme? themeColorSchemeDark,
    ColorScheme? themeColorSchemeLight,
  }) {
    return SettingsState(
      brightnessMode: brightnessMode ?? this.brightnessMode,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      themeColorSchemeDark: themeColorSchemeDark ?? this.themeColorSchemeDark,
      themeColorSchemeLight:
          themeColorSchemeLight ?? this.themeColorSchemeLight,
    );
  }
}
