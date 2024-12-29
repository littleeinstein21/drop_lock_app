import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<String> registeredUIDs = [];

  @override
  void initState() {
    super.initState();

    // Listen to changes in the Firebase data
    _database.child("fingerprint/registeredUIDs").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Convert the Map keys to List<String>
        setState(() {
          registeredUIDs = data.keys.map((e) => e.toString()).toList();
        });
      }
    });
  }

  // Function to rename UID
  Future<void> _renameUID(int index) async {
    TextEditingController controller = TextEditingController();
    controller.text = registeredUIDs[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Rename UID', style: GoogleFonts.poppins(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new UID name',
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.tealAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final newUID = controller.text.trim();
                if (newUID.isNotEmpty) {
                  // Update UID in Firebase
                  _database
                      .child("fingerprint/registeredUIDs")
                      .child(registeredUIDs[index])
                      .remove();
                  _database
                      .child("fingerprint/registeredUIDs")
                      .child(newUID)
                      .set(true);
                }
                Navigator.pop(context);
              },
              child: Text('Rename', style: GoogleFonts.poppins(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete UID
  Future<void> _deleteUID(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete UID', style: GoogleFonts.poppins(color: Colors.white)),
          content: Text('Are you sure you want to delete this UID?',
              style: GoogleFonts.poppins(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                // Remove UID from Firebase
                _database
                    .child("fingerprint/registeredUIDs")
                    .child(registeredUIDs[index])
                    .remove();
                Navigator.pop(context);
              },
              child: Text('Delete', style: GoogleFonts.poppins(color: Colors.greenAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registered UIDs',
              style: GoogleFonts.poppins(
                color: Colors.tealAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: registeredUIDs.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[850],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.fingerprint, color: Colors.tealAccent),
                      title: Text(
                        "UID: ${registeredUIDs[index]}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        color: Colors.grey[850],
                        onSelected: (value) {
                          if (value == 'rename') {
                            _renameUID(index);
                          } else if (value == 'delete') {
                            _deleteUID(index);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'rename',
                            child: Text('Rename', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
