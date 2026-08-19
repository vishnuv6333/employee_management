import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardOrder extends DashboardEvent {}

class ReorderDashboardCards extends DashboardEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderDashboardCards(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}
