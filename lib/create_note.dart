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
        title: const Text("Create", style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.done, color: Colors.white,),
            onPressed: _saveNote, // Save note on tap
          ),
        ],
      ),
      body: Container( decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.deepPurpleAccent]),),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Title", labelStyle: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Description", labelStyle: TextStyle(color: Colors.white)),
                maxLines: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
