import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/theme_bloc.dart';
import 'features/settings/presentation/bloc/theme_state.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/bloc/notes_event.dart';

import 'core/notifications/notification_service.dart';

import 'core/notifications/notification_permission_gate.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await di.sl<NotificationService>().init();
  runApp(const SmartWorkspaceApp());
}

class SmartWorkspaceApp extends StatelessWidget {
  const SmartWorkspaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeBloc>()),
        BlocProvider(create: (_) => di.sl<NotesBloc>()..add(LoadNotes())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'Smart Workspace',
            theme: AppTheme.lightTheme(themeState.seedColor),
            darkTheme: AppTheme.darkTheme(themeState.seedColor),
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return NotificationPermissionGate(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
