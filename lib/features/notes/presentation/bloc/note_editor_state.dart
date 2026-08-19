import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

class NoteEditorState extends Equatable {
  final String noteId;
  final String title;
  final String description;
  final List<ChecklistItem> checklist;
  final List<String> images;
  final bool isDirty;
  final DateTime createdAt;
  final String color;
  final bool isArchived;

  const NoteEditorState({
    required this.noteId,
    this.title = '',
    this.description = '',
    this.checklist = const [],
    this.images = const [],
    this.isDirty = false,
    required this.createdAt,
    this.color = '#FFFFFF',
    this.isArchived = false,
  });

  NoteEditorState copyWith({
    String? noteId,
    String? title,
    String? description,
    List<ChecklistItem>? checklist,
    List<String>? images,
    bool? isDirty,
    DateTime? createdAt,
    String? color,
    bool? isArchived,
  }) {
    return NoteEditorState(
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      description: description ?? this.description,
      checklist: checklist ?? this.checklist,
      images: images ?? this.images,
      isDirty: isDirty ?? this.isDirty,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Note toNote() {
    return Note(
      id: noteId,
      title: title.trim(),
      description: description.trim(),
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      color: color,
      images: images,
      checklist: checklist,
    );
  }

  @override
  List<Object> get props => [
        noteId,
        title,
        description,
        checklist,
        images,
        isDirty,
        createdAt,
        color,
        isArchived,
      ];
}
