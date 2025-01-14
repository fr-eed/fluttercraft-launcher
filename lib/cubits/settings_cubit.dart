import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/material.dart";

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleBrightness() {
    emit(state.copyWith(
      isDarkMode: !state.isDarkMode,
    ));
  }

  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  void toggleNotifications(bool enabled) {
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  void selectImage(String key) {
    emit(state.copyWith(selectedImageKey: key));
  }

  Future<void> updateThemeFromImage(String imagePath) async {
    final colorScheme = await ColorScheme.fromImageProvider(
      provider: AssetImage(imagePath),
    );
    emit(state.copyWith(themeColorScheme: colorScheme));
  }
}

class SettingsState {
  final bool isDarkMode;
  final double fontSize;
  final bool notificationsEnabled;
  final String? selectedImageKey;
  final ColorScheme? themeColorScheme;

  const SettingsState({
    this.isDarkMode = false,
    this.fontSize = 14.0,
    this.notificationsEnabled = true,
    this.selectedImageKey,
    this.themeColorScheme,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    double? fontSize,
    bool? notificationsEnabled,
    String? selectedImageKey,
    ColorScheme? themeColorScheme,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedImageKey: selectedImageKey ?? this.selectedImageKey,
      themeColorScheme: themeColorScheme ?? this.themeColorScheme,
    );
  }
}
