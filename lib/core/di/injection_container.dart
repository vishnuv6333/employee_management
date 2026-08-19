import 'package:employee_manage/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features - Settings / Theme
  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));
}
