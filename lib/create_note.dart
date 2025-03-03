import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNotePage extends StatefulWidget {
  final String? noteId;
  final String? title;
  final String? description;

  const CreateNotePage({super.key, this.noteId, this.title, this.description});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // If editing, prefill the text fields
    if (widget.title != null && widget.description != null) {
      _titleController.text = widget.title!;
      _descriptionController.text = widget.description!;
    }
  }

  void _saveNote() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) return;

    if (widget.noteId == null) {
      // Creating a new note
      await _firestore.collection("notes").add({
        "title": title,
        "description": description,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } else {
      // Updating an existing note
      await _firestore.collection("notes").doc(widget.noteId).update({
        "title": title,
        "description": description,
      });
    }

    Navigator.pop(context); // Go back to HomePage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create / Edit Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote, // Save note on tap
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
