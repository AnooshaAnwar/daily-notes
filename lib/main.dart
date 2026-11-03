
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

// APP COLORS
const Color cream = Color(0xFFFAF6F1);
const Color brown = Color(0xFF654B3C);
const Color lightBrown = Color(0xFF9B7863);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightBrown,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// HOME SCREEN
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, String>> notes = [];

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

  bool isLoading = true;

  // SAMPLE NOTES
  final List<Map<String, String>> sampleNotes = [
    {
      'title': 'My First Note',
      'description': 'Welcome to my Daily Notes app!',
    },
    {
      'title': 'Shopping List',
      'description': 'Milk, bread, eggs and coffee.',
    },
    {
      'title': 'My Ideas',
      'description': 'Some new ideas for my projects.',
    },
  ];

  // LOAD NOTES WHEN APP STARTS
  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  // LOAD SAVED NOTES
  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString('daily_notes');

    if (!mounted) return;

    setState(() {
      if (savedData != null) {
        final List<dynamic> decodedData =
        jsonDecode(savedData);

        notes = decodedData.map((item) {
          return Map<String, String>.from(item);
        }).toList();
      } else {
        notes = List.from(sampleNotes);
      }

      isLoading = false;
    });

    if (savedData == null) {
      await saveNotes();
    }
  }

  // SAVE NOTES PERMANENTLY
  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(notes);

    await prefs.setString('daily_notes', encodedData);
  }

  // SEARCH NOTES
  List<Map<String, String>> get filteredNotes {
    return notes.where((note) {
      return note['title']!
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          note['description']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  // ADD OR EDIT NOTE
  void openNoteForm({int? index}) {
    final titleController = TextEditingController(
      text: index == null ? '' : notes[index]['title'],
    );

    final descriptionController = TextEditingController(
      text: index == null
          ? ''
          : notes[index]['description'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cream,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 25,
            bottom:
            MediaQuery.of(sheetContext).viewInsets.bottom + 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  index == null
                      ? 'Create New Note'
                      : 'Edit Note',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Note Title',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Write your note...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(15),
                    ),

                    onPressed: () async {
                      final title =
                      titleController.text.trim();

                      final description =
                      descriptionController.text.trim();

                      if (title.isEmpty ||
                          description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill in both fields!',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        if (index == null) {
                          notes.add({
                            'title': title,
                            'description': description,
                          });
                        } else {
                          notes[index] = {
                            'title': title,
                            'description': description,
                          };
                        }
                      });

                      await saveNotes();

                      if (mounted && sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },

                    child: Text(
                      index == null
                          ? 'Save Note'
                          : 'Update Note',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  // DELETE NOTE
  Future<void> deleteNote(int index) async {
    setState(() {
      notes.removeAt(index);
    });

    await saveNotes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note deleted successfully!'),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // BUILD HOME SCREEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        backgroundColor: cream,
        title: const Text(
          'Daily Notes ♡',
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Hello there!',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: brown,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Keep your thoughts in one place.',
              style: TextStyle(
                color: lightBrown,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            // SEARCH BAR
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search your notes...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: lightBrown,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // NOTES HEADING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Notes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: brown,
                  ),
                ),

                Text(
                  '${filteredNotes.length} Notes',
                  style: const TextStyle(
                    color: lightBrown,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // NOTES LIST
            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: lightBrown,
                ),
              )
                  : filteredNotes.isEmpty
                  ? const Center(
                child: Text(
                  'No notes found ♡',
                  style: TextStyle(
                    color: lightBrown,
                    fontSize: 17,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];

                  final actualIndex =
                  notes.indexOf(note);

                  return Card(
                    color: Colors.white,
                    elevation: 1,
                    margin: const EdgeInsets.only(
                      bottom: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(12),

                      child: ListTile(
                        title: Text(
                          note['title']!,
                          style: const TextStyle(
                            color: brown,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        subtitle: Padding(
                          padding:
                          const EdgeInsets.only(top: 8),
                          child: Text(
                            note['description']!,
                            style: const TextStyle(
                              color: lightBrown,
                            ),
                          ),
                        ),

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: lightBrown,
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              openNoteForm(
                                index: actualIndex,
                              );
                            } else if (value == 'delete') {
                              deleteNote(actualIndex);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ADD NOTE BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: lightBrown,
        foregroundColor: Colors.white,
        onPressed: () => openNoteForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
