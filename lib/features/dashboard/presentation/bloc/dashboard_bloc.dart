import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/dashboard_card_type.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

const String _dashboardOrderKey = 'dashboard_order';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SharedPreferences sharedPreferences;

  DashboardBloc({required this.sharedPreferences}) : super(DashboardInitial()) {
    on<LoadDashboardOrder>((event, emit) {
      final String? savedOrder = sharedPreferences.getString(_dashboardOrderKey);
      List<DashboardCardType> order;

      if (savedOrder != null) {
        final List<dynamic> decoded = json.decode(savedOrder);
        order = decoded.map((e) => DashboardCardType.values.firstWhere((type) => type.name == e)).toList();
        
        // Ensure all types are present in case new ones were added
        for (var type in DashboardCardType.values) {
          if (!order.contains(type)) {
            order.add(type);
          }
        }
      } else {
        order = DashboardCardType.values.toList();
      }

      emit(DashboardLoaded(order));
    });

    on<ReorderDashboardCards>((event, emit) async {
      if (state is DashboardLoaded) {
        final currentOrder = List<DashboardCardType>.from((state as DashboardLoaded).cardOrder);
        
        int oldIndex = event.oldIndex;
        int newIndex = event.newIndex;
        
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        
        final item = currentOrder.removeAt(oldIndex);
        currentOrder.insert(newIndex, item);
        
        await sharedPreferences.setString(
          _dashboardOrderKey,
          json.encode(currentOrder.map((e) => e.name).toList()),
        );
        
        emit(DashboardLoaded(currentOrder));
      }
    });
  }
}
