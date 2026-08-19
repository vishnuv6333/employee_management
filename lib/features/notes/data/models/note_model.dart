import 'dart:convert';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    required super.color,
    required super.images,
    required super.checklist,
  });

  factory NoteModel.fromJson(Map<String, dynamic> jsonMap) {
    return NoteModel(
      id: jsonMap['id'],
      title: jsonMap['title'],
      description: jsonMap['description'],
      isArchived: jsonMap['isArchived'] == 1,
      createdAt: DateTime.parse(jsonMap['createdAt']),
      updatedAt: DateTime.parse(jsonMap['updatedAt']),
      color: jsonMap['color'],
      images: jsonMap['images'] != null
          ? List<String>.from(json.decode(jsonMap['images']))
          : [],
      checklist: jsonMap['checklist'] != null
          ? (json.decode(jsonMap['checklist']) as List)
              .map((e) => ChecklistItemModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isArchived': isArchived ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'color': color,
      'images': json.encode(images),
      'checklist': json.encode(checklist
          .map((e) => ChecklistItemModel(title: e.title, isCompleted: e.isCompleted).toJson())
          .toList()),
    };
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      description: note.description,
      isArchived: note.isArchived,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      color: note.color,
      images: note.images,
      checklist: note.checklist,
    );
  }
}

class ChecklistItemModel extends ChecklistItem {
  const ChecklistItemModel({
    required super.title,
    required super.isCompleted,
  });

  factory ChecklistItemModel.fromJson(Map<String, dynamic> jsonMap) {
    return ChecklistItemModel(
      title: jsonMap['title'],
      isCompleted: jsonMap['isCompleted'] == 1 || jsonMap['isCompleted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
