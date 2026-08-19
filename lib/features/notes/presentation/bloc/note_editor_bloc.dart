import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'note_editor_event.dart';
import 'note_editor_state.dart';

class NoteEditorBloc extends Bloc<NoteEditorEvent, NoteEditorState> {
  NoteEditorBloc()
      : super(NoteEditorState(
          noteId: const Uuid().v4(),
          createdAt: DateTime.now(),
        )) {
    on<InitializeNote>((event, emit) {
      if (event.note != null) {
        emit(NoteEditorState(
          noteId: event.note!.id,
          title: event.note!.title,
          description: event.note!.description,
          checklist: List.from(event.note!.checklist),
          images: List.from(event.note!.images),
          isDirty: false,
          createdAt: event.note!.createdAt,
          color: event.note!.color,
          isArchived: event.note!.isArchived,
        ));
      } else {
        emit(NoteEditorState(
          noteId: const Uuid().v4(),
          createdAt: DateTime.now(),
          isDirty: false,
        ));
      }
    });

    on<TitleChanged>((event, emit) {
      emit(state.copyWith(title: event.title, isDirty: true));
    });

    on<DescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description, isDirty: true));
    });

    on<ChecklistItemAdded>((event, emit) {
      final checklist = List.of(state.checklist)..add(event.item);
      emit(state.copyWith(checklist: checklist, isDirty: true));
    });

    on<ChecklistItemUpdated>((event, emit) {
      final checklist = List.of(state.checklist);
      checklist[event.index] = event.item;
      emit(state.copyWith(checklist: checklist, isDirty: true));
    });

    on<ChecklistItemRemoved>((event, emit) {
      final checklist = List.of(state.checklist)..removeAt(event.index);
      emit(state.copyWith(checklist: checklist, isDirty: true));
    });

    on<ImageAdded>((event, emit) {
      final images = List.of(state.images)..add(event.imagePath);
      emit(state.copyWith(images: images, isDirty: true));
    });

    on<ImageRemoved>((event, emit) {
      final images = List.of(state.images)..removeAt(event.index);
      emit(state.copyWith(images: images, isDirty: true));
    });

    on<MarkDirty>((event, emit) {
      emit(state.copyWith(isDirty: true));
    });
  }
}
