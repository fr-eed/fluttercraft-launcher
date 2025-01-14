import 'package:fluttcraft_launcher/screens/play_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'constants.dart';
import 'home.dart';
import 'package:go_router/go_router.dart';
import 'screens/instance_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Home(
          index: 0,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return PlayScreen(imageSelected: ColorImageProvider.spring);
          },
        ),
        GoRoute(
          path: '/instances',
          builder: (context, state) {
            return InstancesScreen();
          },
        ),
      ],
    ),
  ],
);

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

  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (BuildContext context) => SettingsCubit(),
        ),
      ],
      child: App(),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: context.read<SettingsCubit>().state.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
            ),
            useMaterial3: true,
          ),
          routeInformationProvider: _router.routeInformationProvider,
          routeInformationParser: _router.routeInformationParser,
          routerDelegate: _router.routerDelegate,
        );
      },
    );
  }
}
