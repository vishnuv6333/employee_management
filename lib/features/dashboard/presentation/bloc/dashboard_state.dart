import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_card_type.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<DashboardCardType> cardOrder;

  const DashboardLoaded(this.cardOrder);

  @override
  List<Object> get props => [cardOrder];
}
