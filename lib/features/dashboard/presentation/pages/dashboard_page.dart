import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/dashboard_card_type.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DashboardBloc>()..add(LoadDashboardOrder()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Workspace'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            return _buildReorderableList(context, state.cardOrder);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildReorderableList(
    BuildContext context,
    List<DashboardCardType> cards,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If tablet/desktop, limit width for better UX
        double horizontalPadding = constraints.maxWidth > 800
            ? (constraints.maxWidth - 600) / 2
            : 16.0;

        return ReorderableListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          onReorder: (oldIndex, newIndex) {
            context.read<DashboardBloc>().add(
              ReorderDashboardCards(oldIndex, newIndex),
            );
          },
          children: cards
              .map((type) => _buildCard(type, ValueKey(type.name)))
              .toList(),
        );
      },
    );
  }

  Widget _buildCard(DashboardCardType type, Key key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCardContent(type),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(DashboardCardType type) {
    switch (type) {
      case DashboardCardType.greeting:
        return const Text('Good Morning, Employee!');
      case DashboardCardType.todaysTasks:
        return const Text('You have 3 tasks for today.');
      case DashboardCardType.notesCount:
        return const Text('5 Notes created.');
      case DashboardCardType.weather:
        return const Row(
          children: [
            Icon(Icons.wb_sunny, color: Colors.orange),
            SizedBox(width: 8),
            Text('72°F, Sunny'),
          ],
        );
      case DashboardCardType.waterIntake:
        return const Text('4 / 8 glasses today');
      case DashboardCardType.focusTimer:
        return const Text('Next session: 25 mins');
    }
  }
}
