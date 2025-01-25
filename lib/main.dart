// Flutter framework
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Navigation
import 'package:go_router/go_router.dart';

// State management & persistence
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// Window management
import 'package:window_manager/window_manager.dart';

import 'package:protocol_handler/protocol_handler.dart';

// Screen imports
import 'screens/instance_screen.dart';
import 'screens/play_screen.dart';
import 'screens/skins_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/settings_screen.dart';

// Local imports
import 'constants.dart';
import 'cubits/settings_cubit.dart';
import 'home.dart';
import 'cubits/auth_cubit.dart';
import 'ui/fade_transition_page.dart';

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
        GoRoute(
          path: '/skins',
          builder: (context, state) {
            return SkinGridScreen();
          },
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) {
            return AuthScreen();
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) {
            return SettingsScreen();
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await protocolHandler.register('fluttercraft');

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );

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
          create: (context) => SettingsCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        )
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
        final themeManager = ThemeManager(state, context);
        return MaterialApp.router(
          theme: ThemeData(
            colorScheme: themeManager.themeColorScheme,
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
