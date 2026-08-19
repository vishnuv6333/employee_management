import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/note_editor_bloc.dart';
import '../bloc/note_editor_event.dart';
import '../bloc/note_editor_state.dart';
import '../../domain/entities/note.dart';
import '../widgets/note_editor_app_bar.dart';
import '../widgets/note_editor_bottom_bar.dart';
import '../widgets/note_editor_image_list.dart';
import '../widgets/note_editor_checklist.dart';

class NoteEditorPage extends StatelessWidget {
  final Note? note;

  const NoteEditorPage({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<NoteEditorBloc>()..add(InitializeNote(note)),
      child: const _NoteEditorView(),
    );
  }
}

class _NoteEditorView extends StatefulWidget {
  const _NoteEditorView();

  @override
  State<_NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<_NoteEditorView> {
  late TextEditingController _titleController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    final state = context.read<NoteEditorBloc>().state;
    _titleController = TextEditingController(text: state.title);
    _descController = TextEditingController(text: state.description);

    _titleController.addListener(() {
      context.read<NoteEditorBloc>().add(TitleChanged(_titleController.text));
    });
    _descController.addListener(() {
      context.read<NoteEditorBloc>().add(
        DescriptionChanged(_descController.text),
      );
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveNote(BuildContext context) {
    final state = context.read<NoteEditorBloc>().state;
    if (state.title.trim().isEmpty && state.description.trim().isEmpty) {
      return; // Don't save empty notes
    }
    context.read<NotesBloc>().add(AddNote(state.toNote()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteEditorBloc, NoteEditorState>(
      buildWhen: (previous, current) => previous.isDirty != current.isDirty || previous.noteId != current.noteId,
      builder: (context, state) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            if (state.isDirty) {
              _saveNote(context);
            }
            return true;
          },
          child: Scaffold(
            appBar: NoteEditorAppBar(
              onSave: () => _saveNote(context),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Hero(
                    tag: 'note_title_${state.noteId}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _descController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Note details...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const NoteEditorImageList(),
                  const NoteEditorChecklist(),
                ],
              ),
            ),
            bottomNavigationBar: const NoteEditorBottomBar(),
          ),
        );
      },
    );
  }
}
