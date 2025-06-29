import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodPickerSheet extends StatelessWidget {
  final String username;

  MoodPickerSheet({super.key, required this.username});

  final List<Map<String, String>> moods = [
    {"emoji": "😊", "label": "Happy"},
    {"emoji": "😔", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😌", "label": "Calm"},
    {"emoji": "😢", "label": "Crying"},
    {"emoji": "😂", "label": "Joyful"},
    {"emoji": "😰", "label": "Anxious"},
    {"emoji": "🥱", "label": "Sleepy"},
    {"emoji": "🤒", "label": "Sick"},
    {"emoji": "🤩", "label": "Excited"},
    {"emoji": "🥺", "label": "Lonely"},
    {"emoji": "😶", "label": "Numb"},
    {"emoji": "😎", "label": "Confident"},
    {"emoji": "😕", "label": "Confused"},
    {"emoji": "😤", "label": "Frustrated"},
  ];

  Future<void> saveMood(String mood, BuildContext context) async {
    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";

    await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("mood")
        .doc(date)
        .set({
      "mood": mood,
      "timestamp": DateTime.now(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Mood saved as $mood!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF205781),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "How are you feeling today?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    final mood = moods[index];
                    return GestureDetector(
                      onTap: () => saveMood(mood["label"]!, context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                mood["emoji"]!,
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                mood["label"]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              )
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
        );
      },
    );
  }
}
