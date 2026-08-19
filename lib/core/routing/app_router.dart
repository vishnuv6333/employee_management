import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notes/presentation/pages/notes_page.dart';
import '../../features/notes/presentation/pages/archived_notes_page.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/notes/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/native_demo_page.dart';
import '../../features/notes/domain/entities/note.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.notes,
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: AppRoutes.archived,
      builder: (context, state) => const ArchivedNotesPage(),
    ),
    GoRoute(
      path: AppRoutes.noteEditor,
      builder: (context, state) {
        final note = state.extra as Note?;
        return NoteEditorPage(note: note);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.nativeDemo,
      builder: (context, state) => const NativeDemoPage(),
    ),
  ],
);
