import 'package:employee_manage/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/network/sync_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/presentation/bloc/note_editor_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // Repositories
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(databaseHelper: sl()),
  );

  // Core Features
  sl.registerLazySingleton(() => SyncService(noteRepository: sl())..init());
  sl.registerLazySingleton(() => NotificationService());

  // Features
  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));
  sl.registerFactory(() => DashboardBloc(sharedPreferences: sl()));
  sl.registerFactory(() => NotesBloc(
        repository: sl(),
        sharedPreferences: sl(),
        syncService: sl(),
      ));
  sl.registerFactory(() => NoteEditorBloc());
}
