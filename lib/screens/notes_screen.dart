
import 'package:flutter/material.dart';
import 'package:project/hive%20classes/boxes.dart';
import 'package:project/hive%20classes/note.dart';
import 'package:uuid/uuid.dart';

class NotesScreen extends StatefulWidget {

  NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notesList = [];

  void _updateNotes() async {
    final List<dynamic> notes = boxNotes.values.toList();
    notesList.clear();
    for (var note in notes) {
      final noteMap = {
        'id' : note.id,
        'note': note.note,
      };
      notesList.add(noteMap);
    }
  }

  final uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    _updateNotes();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anotações'),
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 20, 20, 20),
              Color.fromARGB(255, 20, 20, 20)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: notesList.length,
          itemBuilder: (context, index) {
            final note = notesList[index];
            return Dismissible(
              key: Key(note['id']),
              onDismissed: (direction) {
                setState(() {
                  _deleteNote(note);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    note['note'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: const Icon(Icons.drag_handle),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog(context);
        },
        backgroundColor: const Color.fromARGB(255, 40, 40, 40),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final TextEditingController _noteController = TextEditingController();
    String newNote = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              const Color.fromARGB(255, 40, 40, 40), // Cor de fundo dourada
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar Nova Nota',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _noteController,
                  onChanged: (value) {
                    newNote = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Escreva sua nota aqui...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    fillColor: Colors.white, // Cor de preenchimento branca
                    filled: true,
                    counterStyle: TextStyle(color: Colors.white),
                  ),
                  maxLength: 150,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.black), // Texto preto
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _addNote(newNote);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Cor de fundo branca
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text(
                    'Salvar Nota',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addNote(String newNote) {
    if (newNote.isNotEmpty) {
      var uniqueId = uuid.v4();
      boxNotes.put(
        uniqueId,
        Note(
          id: uniqueId,
          note: newNote,
        ));
    }
  }

  void _deleteNote(Map<String, dynamic> note) {
    if (note.containsKey('id')) {
      final String noteId = note['id'];
      boxNotes.delete(noteId);
      notesList.removeWhere((item) => item['id'] == noteId);
    }
  }
}
