enum DashboardCardType {
  greeting,
  todaysTasks,
  notesCount,
  weather,
  waterIntake,
  focusTimer,
}

extension DashboardCardTypeExtension on DashboardCardType {
  String get title {
    switch (this) {
      case DashboardCardType.greeting:
        return 'Greeting';
      case DashboardCardType.todaysTasks:
        return 'Today \'s Tasks';
      case DashboardCardType.notesCount:
        return 'Notes Count';
      case DashboardCardType.weather:
        return 'Weather';
      case DashboardCardType.waterIntake:
        return 'Water Intake';
      case DashboardCardType.focusTimer:
        return 'Focus Timer';
    }
  }
}
