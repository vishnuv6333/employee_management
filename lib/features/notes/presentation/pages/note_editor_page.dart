import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../../domain/entities/note.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note;

  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late List<ChecklistItem> _checklist;
  late List<String> _images;

  // To handle saving when popped
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descController = TextEditingController(
      text: widget.note?.description ?? '',
    );
    _checklist = widget.note?.checklist != null
        ? List.from(widget.note!.checklist)
        : [];
    _images = widget.note?.images != null ? List.from(widget.note!.images) : [];

    _titleController.addListener(_markDirty);
    _descController.addListener(_markDirty);
  }

  void _markDirty() {
    _isDirty = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveNote(BuildContext context) {
    if (_titleController.text.trim().isEmpty &&
        _descController.text.trim().isEmpty) {
      return; // Don't save empty notes
    }

    final now = DateTime.now();
    final isNew = widget.note == null;

    final note = Note(
      id: isNew ? const Uuid().v4() : widget.note!.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      isArchived: widget.note?.isArchived ?? false,
      createdAt: isNew ? now : widget.note!.createdAt,
      updatedAt: now,
      color: widget.note?.color ?? '#FFFFFF',
      images: _images,
      checklist: _checklist,
    );

    if (isNew) {
      context.read<NotesBloc>().add(AddNote(note));
    } else {
      context.read<NotesBloc>().add(UpdateNote(note));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async {
            if (_isDirty) {
              _saveNote(context);
            }
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                if (widget.note != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<NotesBloc>().add(
                        DeleteNote(widget.note!.id),
                      );
                      context.pop();
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    _saveNote(context);
                    _isDirty = false;
                    context.pop();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Hero(
                    tag: widget.note != null
                        ? 'note_title_${widget.note!.id}'
                        : 'new_note_title',
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
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_images[index]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _images.removeAt(index);
                                        _markDirty();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (_checklist.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Checklist',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._checklist.asMap().entries.map((entry) {
                      int idx = entry.key;
                      ChecklistItem item = entry.value;
                      return CheckboxListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        value: item.isCompleted,
                        onChanged: (val) {
                          setState(() {
                            _checklist[idx] = ChecklistItem(
                              title: item.title,
                              isCompleted: val ?? false,
                            );
                            _markDirty();
                          });
                        },
                        secondary: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _checklist.removeAt(idx);
                              _markDirty();
                            });
                          },
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_task),
                    tooltip: 'Add Checklist Item',
                    onPressed: () {
                      _showAddChecklistDialog(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    tooltip: 'Add Image',
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          _images.add(image.path);
                          _markDirty();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddChecklistDialog(BuildContext context) {
    final TextEditingController checklistController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Checklist Item'),
          content: TextField(
            controller: checklistController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Item description'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (checklistController.text.trim().isNotEmpty) {
                  setState(() {
                    _checklist.add(
                      ChecklistItem(
                        title: checklistController.text.trim(),
                        isCompleted: false,
                      ),
                    );
                    _markDirty();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
