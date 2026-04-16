import 'package:flutter/material.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class EditNotePage extends StatefulWidget {
  final Note? note;

  const EditNotePage({super.key, this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.note?.title ?? "");
    contentController =
        TextEditingController(text: widget.note?.content ?? "");
    selectedDate = widget.note?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void saveNote() {
    final note = Note(
      id: widget.note?.id ?? Random().nextDouble().toString(),
      title: titleController.text,
      content: contentController.text,
      date: selectedDate,
    );

    Navigator.pop(context, note);
  }

  void deleteNote() {
    if (widget.note != null) {
      Navigator.pop(context, {"delete": widget.note!.id});
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: deleteNote,
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATE
            GestureDetector(
              onTap: pickDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 10),
                  Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // TITLE
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),

            const SizedBox(height: 10),

            // CONTENT
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Write your notes...",
                  border: InputBorder.none,
                ),
              ),
            ),

            // SAVE
            ElevatedButton(
              onPressed: saveNote,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}