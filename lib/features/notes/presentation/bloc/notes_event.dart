import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotes extends NotesEvent {}

class LoadArchivedNotes extends NotesEvent {}

class SearchNotes extends NotesEvent {
  final String query;
  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

class AddNote extends NotesEvent {
  final Note note;
  const AddNote(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNote extends NotesEvent {
  final Note note;
  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNote extends NotesEvent {
  final String id;
  const DeleteNote(this.id);

  @override
  List<Object?> get props => [id];
}

class ArchiveNote extends NotesEvent {
  final String id;
  const ArchiveNote(this.id);

  @override
  List<Object?> get props => [id];
}

class GenerateMockData extends NotesEvent {}
