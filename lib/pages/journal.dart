import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'new_journal.dart';
import 'old_journal.dart';

class JournalPage extends StatelessWidget {
  final String username;

  const JournalPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(username)
            .collection("journals")
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No journal entries yet.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final journals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final doc = journals[index];
              final title = doc.id;
              final content = doc.get("content") ?? "";

              return Card(
                color: Color(0xFF2B2B52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    content.length > 50
                        ? "${content.substring(0, 50)}..."
                        : content,
                    style: TextStyle(color: Colors.white70),
                  ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OldJournalPage(
                            journalTitle: title,
                            content: content,
                          ),
                        ),
                      );
                    },

                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewJournalPage(username: username),
            ),
          );
        },
        backgroundColor: Color(0xFF98A1BC),
        shape: const StadiumBorder(),
        child: Icon(
          CupertinoIcons.add_circled_solid,
          color: Colors.black,
        ),
      ),
    );
  }
}