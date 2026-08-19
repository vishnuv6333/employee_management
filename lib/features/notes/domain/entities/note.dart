import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String color;
  final List<String> images;
  final List<ChecklistItem> checklist;

  const Note({
    required this.id,
    required this.title,
    required this.description,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
    required this.images,
    required this.checklist,
  });

  Note copyWith({
    String? id,
    String? title,
    String? description,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    List<String>? images,
    List<ChecklistItem>? checklist,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      images: images ?? this.images,
      checklist: checklist ?? this.checklist,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isArchived,
        createdAt,
        updatedAt,
        color,
        images,
        checklist,
      ];
}

class ChecklistItem extends Equatable {
  final String title;
  final bool isCompleted;

  const ChecklistItem({
    required this.title,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [title, isCompleted];
}
