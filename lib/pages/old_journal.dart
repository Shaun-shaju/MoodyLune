import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OldJournalPage extends StatelessWidget {
  final String journalTitle;
  final String content;

  const OldJournalPage({
    super.key,
    required this.journalTitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Journal — $journalTitle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2B2B52),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content,
                    style: GoogleFonts.twinkleStar(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
