import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../../domain/entities/note.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query, BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        context.read<NotesBloc>().add(SearchNotes(query.trim()));
      } else {
        context.read<NotesBloc>().add(LoadNotes());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
              ),
              onChanged: (val) => _onSearchChanged(val, context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<NotesBloc>().add(LoadNotes());
                },
              ),
            ],
          ),
          body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              if (state is NotesLoading) {
                return const CardSkeletonList();
              } else if (state is NotesLoaded) {
                final notes = state.notes;
                if (notes.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return _buildSearchNoteCard(
                      context,
                      notes[index],
                      _searchController.text,
                    );
                  },
                );
              } else if (state is NotesError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong.',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We encountered an error during search: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotesBloc>().add(SearchNotes(_searchController.text.trim()));
                          },
                          child: const Text('Try Again'),
                        )
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text('Start typing to search'));
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No matching notes found.',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchNoteCard(BuildContext context, Note note, String query) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          context.push('/note-editor', extra: note);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HighlightText(text: note.title, keyword: query, isBold: true),
              const SizedBox(height: 8),
              _HighlightText(
                text: note.description,
                keyword: query,
                isBold: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String keyword;
  final bool isBold;

  const _HighlightText({
    required this.text,
    required this.keyword,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    if (keyword.isEmpty ||
        !text.toLowerCase().contains(keyword.toLowerCase())) {
      return Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isBold ? 18 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    final int startIndex = text.toLowerCase().indexOf(keyword.toLowerCase());
    final int endIndex = startIndex + keyword.length;

    final String before = text.substring(0, startIndex);
    final String match = text.substring(startIndex, endIndex);
    final String after = text.substring(endIndex);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: isBold ? 18 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              color: Colors.black,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
