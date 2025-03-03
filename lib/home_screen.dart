import 'package:firebase_task/create_note.dart';
import 'package:firebase_task/edit_note.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {

  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> selectedNotes = []; // Store selected note IDs
  bool isSelectionMode = false; // Toggle selection mode

  void _toggleSelection(String noteId) {
    setState(() {
      if (selectedNotes.contains(noteId)) {
        selectedNotes.remove(noteId);
      } else {
        selectedNotes.add(noteId);
      }
      isSelectionMode = selectedNotes.isNotEmpty;
    });
  }

  void _deleteSelectedNotes() async {
    for (String noteId in selectedNotes) {
      await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
    }
    setState(() {
      selectedNotes.clear();
      isSelectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var userName = widget.userName;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotePage(),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        title: Text(isSelectionMode ? "${selectedNotes.length} Selected" : "$userName's Notes", style: const TextStyle(color: Colors.white),),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  setState(() {
                    selectedNotes.clear();
                    isSelectionMode = false;
                  });
                },
              )
            : null,
        flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepPurple, Colors.deepPurpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black),
                  onPressed: _deleteSelectedNotes,
                )
              ]
            : null,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('notes').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            var notes = snapshot.data!.docs;
        
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Display 2 columns
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                var note = notes[index];
                String noteId = note.id;
                String title = note['title'];
                String description = note['description'];
        
                return GestureDetector(
                  onLongPress: () => _toggleSelection(noteId),
                  onTap: () {
                    if (isSelectionMode) {
                      _toggleSelection(noteId);
                    } else {
                      // Open note for editing
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNotePage(noteId: noteId, title: title, description: description),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedNotes.contains(noteId) ? Colors.red[100] : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(description, style: const TextStyle(fontSize: 14, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
