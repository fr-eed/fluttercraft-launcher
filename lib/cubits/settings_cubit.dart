import "package:flutter/material.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void cycleBrightness() {
    switch (state.brightness) {
      case Brightness.light:
        emit(state.copyWith(brightness: Brightness.dark));
      case Brightness.dark:
        emit(state.copyWith(brightness: Brightness.system));
      case Brightness.system:
        emit(state.copyWith(brightness: Brightness.light));
    }
  }

  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  void toggleNotifications(bool enabled) {
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateThemeWithImage(String imagePath) async {
    final colorScheme = await ColorScheme.fromImageProvider(
      brightness: state.brightness,
      provider: AssetImage(imagePath),
    );

    emit(state.copyWith(
      themeColorScheme: colorScheme,
      selectedImagePath: imagePath,
    ));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState(
      brightness: Brightness.values
          .byName(json['brightness'] as String? ?? 'system'),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      selectedImagePath: json['selectedImagePath'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'brightness': state.brightness.name,
      'fontSize': state.fontSize,
      'notificationsEnabled': state.notificationsEnabled,
      'selectedImagePath': state.selectedImagePath,
    };
  }
}

enum Brightness { light, dark, system }

class SettingsState {
  final Brightness brightness;
  final double fontSize;
  final bool notificationsEnabled;
  final String selectedImagePath;
  final ColorScheme? themeColorScheme;

  const SettingsState({
    this.brightness = Brightness.system,
    this.fontSize = 14.0,
    this.notificationsEnabled = true,
    this.selectedImagePath = 'assets/bg_spring.webp',
    this.themeColorScheme,
  });

  SettingsState copyWith({
    Brightness? brightness,
    double? fontSize,
    bool? notificationsEnabled,
    String? selectedImagePath,
    ColorScheme? themeColorScheme,
  }) {
    return SettingsState(
      brightness: brightness ?? this.brightness,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      themeColorScheme: themeColorScheme ?? this.themeColorScheme,
    );
  }
