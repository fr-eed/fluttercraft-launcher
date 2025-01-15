import "package:flutter/material.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void cycleBrightness() {
    switch (state.themeBrightness) {
      case Brightness.light:
        emit(state.copyWith(brightness: Brightness.dark));
      case Brightness.dark:
        emit(state.copyWith(brightness: Brightness.light));
    }
  }

  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  void setThemeBrightness(Brightness brightness) {
    emit(state.copyWith(brightness: brightness));
  }

  void toggleNotifications(bool enabled) {
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> updateThemeWithImage(String imagePath) async {
    final colorScheme = await ColorScheme.fromImageProvider(
      brightness: state.themeBrightness,
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
      themeBrightness:
          Brightness.values.byName(json['brightness'] as String? ?? 'system'),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      selectedImagePath: json['selectedImagePath'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return {
      'themeBrightness': state.themeBrightness.name,
      'fontSize': state.fontSize,
      'notificationsEnabled': state.notificationsEnabled,
      'selectedImagePath': state.selectedImagePath,
    };
  }
}

class SettingsState {
  final Brightness themeBrightness;
  final double fontSize;
  final bool notificationsEnabled;
  final String selectedImagePath;
  final ColorScheme? themeColorScheme;

  const SettingsState({
    this.themeBrightness = Brightness.light,
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
      themeBrightness: brightness ?? this.themeBrightness,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      themeColorScheme: themeColorScheme ?? this.themeColorScheme,
    );
  }
}
