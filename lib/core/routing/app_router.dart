import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/notes/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/native_demo_page.dart';
import '../../features/notes/domain/entities/note.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/note-editor',
      builder: (context, state) {
        final note = state.extra as Note?;
        return NoteEditorPage(note: note);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/native-demo',
      builder: (context, state) => const NativeDemoPage(),
    ),
  ],
);
