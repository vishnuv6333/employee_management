import 'package:employee_manage/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:employee_manage/features/notes/presentation/bloc/notes_event.dart';
import 'package:employee_manage/features/notes/presentation/bloc/notes_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/sync_service.dart';
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
      body: StreamBuilder<bool>(
        stream: di.sl<SyncService>().offlineStatusStream,
        initialData: di.sl<SyncService>().isOffline,
        builder: (context, offlineSnapshot) {
          final isOffline = offlineSnapshot.data ?? false;
          return Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: isOffline
                    ? Container(
                        width: double.infinity,
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: const Text(
                          'Working Offline',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildDashboardContent(context, state),
                    );
                  },
                ),
              ),
            ],
          );
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

  Widget _buildDashboardContent(BuildContext context, DashboardState state) {
    if (state is DashboardLoaded) {
      return _buildReorderableList(context, state.cardOrder);
    }
    return const CardSkeletonList(key: ValueKey('skeleton'));
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: type == DashboardCardType.notesCount
                ? () => context.push('/notes')
                : null,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _getCardIconBgColor(colorScheme, type),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _getCardIcon(type),
                              color: _getCardIconColor(colorScheme, type),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            type.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.drag_indicator_rounded,
                        color: colorScheme.outlineVariant,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCardContent(context, type),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCardIcon(DashboardCardType type) {
    switch (type) {
      case DashboardCardType.greeting:
        return Icons.waving_hand_rounded;
      case DashboardCardType.todaysTasks:
        return Icons.task_alt_rounded;
      case DashboardCardType.notesCount:
        return Icons.description_rounded;
      case DashboardCardType.weather:
        return Icons.wb_sunny_rounded;
      case DashboardCardType.waterIntake:
        return Icons.water_drop_rounded;
      case DashboardCardType.focusTimer:
        return Icons.timer_rounded;
    }
  }

  Color _getCardIconBgColor(ColorScheme colorScheme, DashboardCardType type) {
    switch (type) {
      case DashboardCardType.greeting:
        return colorScheme.primaryContainer;
      case DashboardCardType.todaysTasks:
        return colorScheme.tertiaryContainer;
      case DashboardCardType.notesCount:
        return colorScheme.secondaryContainer;
      case DashboardCardType.weather:
        return Colors.amber.withValues(alpha: 0.2);
      case DashboardCardType.waterIntake:
        return Colors.blue.withValues(alpha: 0.2);
      case DashboardCardType.focusTimer:
        return Colors.deepOrange.withValues(alpha: 0.2);
    }
  }

  Color _getCardIconColor(ColorScheme colorScheme, DashboardCardType type) {
    switch (type) {
      case DashboardCardType.greeting:
        return colorScheme.onPrimaryContainer;
      case DashboardCardType.todaysTasks:
        return colorScheme.onTertiaryContainer;
      case DashboardCardType.notesCount:
        return colorScheme.onSecondaryContainer;
      case DashboardCardType.weather:
        return Colors.amber.shade800;
      case DashboardCardType.waterIntake:
        return Colors.blue.shade700;
      case DashboardCardType.focusTimer:
        return Colors.deepOrange.shade700;
    }
  }

  Widget _buildCardContent(BuildContext context, DashboardCardType type) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (type) {
      case DashboardCardType.greeting:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, Employee!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ready to tackle your goals for today?',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        );
      case DashboardCardType.todaysTasks:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'You have 3 tasks for today.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      case DashboardCardType.notesCount:
        return BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            final countStr = state is NotesLoaded ? '${state.notes.length}' : '...';
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countStr,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Active Workspace Notes',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.primary, size: 16),
                ),
              ],
            );
          },
        );
      case DashboardCardType.weather:
        return Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '72°F, Sunny',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('San Francisco, CA', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ],
        );
      case DashboardCardType.waterIntake:
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 10,
                  backgroundColor: Colors.blue.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '4 / 8 glasses',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
      case DashboardCardType.focusTimer:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.deepOrange.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '25:00',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text('Pomodoro Session', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        );
    }
  }
}
