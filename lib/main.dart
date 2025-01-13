import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'constants.dart';
import 'home.dart';

Future<void> initializeWindow() async {
  WindowOptions windowOptions = const WindowOptions(
    size: minWindowSize,
    minimumSize: minWindowSize,
    fullScreen: false,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.focus();
  });
}

Future<ColorScheme?> initializeColorScheme(
    ColorSelectionMethod method, ColorImageProvider imageProvider) async {
  if (method == ColorSelectionMethod.image) {
    final String imagePath = imageProvider.path;
    return await ColorScheme.fromImageProvider(provider: AssetImage(imagePath));
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the window
  await initializeWindow();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.baseColor;
  ColorImageProvider imageSelected = ColorImageProvider.winter;
  ColorScheme? imageColorScheme;
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.image;

  bool get useLightMode => switch (themeMode) {
        ThemeMode.system =>
          View.of(context).platformDispatcher.platformBrightness ==
              Brightness.light,
        ThemeMode.light => true,
        ThemeMode.dark => false
      };

  @override
  void initState() {
    super.initState();
    setupInitialColorScheme();
  }

  Future<void> setupInitialColorScheme() async {
    final scheme =
        await initializeColorScheme(colorSelectionMethod, imageSelected);
    setState(() {
      imageColorScheme = scheme;
    });
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleMaterialVersionChange() {
    setState(() {
      useMaterial3 = !useMaterial3;
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;
      colorSelected = ColorSeed.values[value];
    });
  }

  void handleImageSelect(int value) async {
    final selectedImage = ColorImageProvider.values[value];
    final scheme =
        await initializeColorScheme(ColorSelectionMethod.image, selectedImage);
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.image;
      imageSelected = selectedImage;
      imageColorScheme = scheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FluttCraft Launcher',
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color
            : null,
        colorScheme: colorSelectionMethod == ColorSelectionMethod.image
            ? imageColorScheme
            : null,
        useMaterial3: useMaterial3,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelectionMethod == ColorSelectionMethod.colorSeed
            ? colorSelected.color
            : imageColorScheme?.primary,
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,
      ),
      home: Home(
        useLightMode: useLightMode,
        useMaterial3: useMaterial3,
        colorSelected: colorSelected,
        imageSelected: imageSelected,
        handleBrightnessChange: handleBrightnessChange,
        handleMaterialVersionChange: handleMaterialVersionChange,
        handleColorSelect: handleColorSelect,
        handleImageSelect: handleImageSelect,
        colorSelectionMethod: colorSelectionMethod,
      ),
    );
  }
}
