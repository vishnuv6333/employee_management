import 'package:employee_manage/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:employee_manage/features/notes/presentation/bloc/notes_event.dart';
import 'package:employee_manage/features/notes/presentation/bloc/notes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/skeleton_loader.dart';
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            return _buildReorderableList(context, state.cardOrder);
          }
          return const CardSkeletonList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Smart Note',
        onPressed: () {
          context.push('/note-editor').then((_) {
            // ignore: use_build_context_synchronously
            context.read<NotesBloc>().add(LoadNotes());
          });
        },
        child: const Icon(Icons.note_add),
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
              .map((type) => _buildCard(context, type, ValueKey(type.name)))
              .toList(),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, DashboardCardType type, Key key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: type == DashboardCardType.notesCount
              ? () => context.push('/notes')
              : null,
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
                _buildCardContent(context, type),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, DashboardCardType type) {
    switch (type) {
      case DashboardCardType.greeting:
        return const Text('Good Morning, Employee!');
      case DashboardCardType.todaysTasks:
        return const Text('You have 3 tasks for today.');
      case DashboardCardType.notesCount:
        return BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoaded) {
              return Text('${state.notes.length} Notes created.');
            }
            return const Text('Loading...');
          },
        );
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
