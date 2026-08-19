import 'dart:io';
import 'package:employee_manage/features/notes/presentation/bloc/note_editor_bloc.dart';
import 'package:employee_manage/features/notes/presentation/bloc/note_editor_event.dart';
import 'package:employee_manage/features/notes/presentation/bloc/note_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoteEditorImageList extends StatelessWidget {
  const NoteEditorImageList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteEditorBloc, NoteEditorState>(
      buildWhen: (previous, current) => previous.images != current.images,
      builder: (context, state) {
        if (state.images.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Image.file(
                        File(state.images[index]),
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
                            context.read<NoteEditorBloc>().add(
                              ImageRemoved(index),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
