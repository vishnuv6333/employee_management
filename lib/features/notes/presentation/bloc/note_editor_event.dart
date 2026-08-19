import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

abstract class NoteEditorEvent extends Equatable {
  const NoteEditorEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNote extends NoteEditorEvent {
  final Note? note;

  const InitializeNote(this.note);

  @override
  List<Object?> get props => [note];
}

class TitleChanged extends NoteEditorEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

class DescriptionChanged extends NoteEditorEvent {
  final String description;

  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class ChecklistItemAdded extends NoteEditorEvent {
  final ChecklistItem item;

  const ChecklistItemAdded(this.item);

  @override
  List<Object> get props => [item];
}

class ChecklistItemUpdated extends NoteEditorEvent {
  final int index;
  final ChecklistItem item;

  const ChecklistItemUpdated(this.index, this.item);

  @override
  List<Object> get props => [index, item];
}

class ChecklistItemRemoved extends NoteEditorEvent {
  final int index;

  const ChecklistItemRemoved(this.index);

  @override
  List<Object> get props => [index];
}

class ImageAdded extends NoteEditorEvent {
  final String imagePath;

  const ImageAdded(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}

class ImageRemoved extends NoteEditorEvent {
  final int index;

  const ImageRemoved(this.index);

  @override
  List<Object> get props => [index];
}

class MarkDirty extends NoteEditorEvent {}
