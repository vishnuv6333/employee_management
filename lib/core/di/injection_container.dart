import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/settings/presentation/bloc/theme_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features
  sl.registerFactory(() => ThemeBloc(sharedPreferences: sl()));
  sl.registerFactory(() => DashboardBloc(sharedPreferences: sl()));
}
