import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NewJournalPage extends StatefulWidget {
  final String username;

  const NewJournalPage({super.key, required this.username});

  @override
  State<NewJournalPage> createState() => _NewJournalPageState();
}

class _NewJournalPageState extends State<NewJournalPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  late String journalTitle;

  @override
  void initState() {
    super.initState();
    journalTitle = _generateTitle();
  }

  String _generateTitle() {
    final now = DateTime.now();
    final day = now.day;
    final month = DateFormat.MMMM().format(now);
    final year = now.year;

    final suffix = _getDaySuffix(day);
    return "$day$suffix $month, $year";
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "th";
    }
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  Future<void> _saveJournal() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Write something in your journal!")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text(
            "The Journal can’t be edited later on. Do you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
      }

      try {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.username)
            .collection("journals")
            .doc(journalTitle)
            .set({
          "content": content,
          "created_at": FieldValue.serverTimestamp(),
        });
      } finally {
        setState(() {
          _isSaving = false;
        });
        if (mounted) Navigator.pop(context); // Dismiss loading indicator
      }

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

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
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.twinkleStar(
                  color: Colors.white,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: "Write your thoughts here...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color(0xFF2B2B52),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveJournal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF98A1BC),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
                    : const Text("Finish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
