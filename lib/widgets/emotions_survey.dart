import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodylune/pages/mood.dart';

import 'alerts.dart';

class EmotionSurveySheet extends StatefulWidget {
  final String username;

  const EmotionSurveySheet({super.key, required this.username});

  @override
  State<EmotionSurveySheet> createState() => _EmotionSurveySheetState();
}

class _EmotionSurveySheetState extends State<EmotionSurveySheet> {
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> questionsData = [];
  List<String?> selectedAnswers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("questions")
          .doc("latest")
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        questionsData = data.entries.map((e) {
          final question = e.key;
          List<String> options;
          if (e.value is List) {
            options = List<String>.from(e.value);
          } else if (e.value is String) {
            String raw = e.value;
            raw = raw.replaceAll("[", "").replaceAll("]", "");
            options = raw
                .split(",")
                .map((s) => s.trim().replaceAll("'", "").replaceAll('"', ""))
                .toList();
          } else {
            options = [];
          }
          return {
            "question": question,
            "options": options,
          };
        }).toList();

        selectedAnswers = List.filled(questionsData.length, null);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching questions: $e");
    }
  }

  void _nextPage() {
    if (_pageController.page!.toInt() < questionsData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_pageController.page!.toInt() > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (selectedAnswers.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all questions!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";

    final answersMap = {
      for (int i = 0; i < questionsData.length; i++)
        questionsData[i]["question"]: selectedAnswers[i]
    };

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.username)
        .collection("questionnaires")
        .doc(date)
        .set({
      "questions": answersMap,
    });
    void _openGeminiChat() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoodsPage(username: widget.username),
        ),
      );
    }
    showCounsellorChoiceDialog(
      context,
          () {
        Navigator.pop(context);
        _openGeminiChat();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.center,
        child: const CupertinoActivityIndicator(),
      );
    }

    if (questionsData.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        alignment: Alignment.center,
        child: const Text(
          "No questions available.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF205781),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text(
            "Record Your Emotions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questionsData.length,
              itemBuilder: (context, index) {
                return _buildQuestion(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(int index) {
    final question = questionsData[index]["question"] as String;
    final options = questionsData[index]["options"] as List<String>;

    final isLast = index == questionsData.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) {
          return RadioListTile<String>(
            activeColor: const Color(0xFFFFBF78),
            title: Text(
              option,
              style: const TextStyle(color: Colors.white),
            ),
            value: option,
            groupValue: selectedAnswers[index],
            onChanged: (value) {
              setState(() {
                selectedAnswers[index] = value;
              });
            },
          );
        }).toList(),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (index > 0)
              ElevatedButton(
                onPressed: _prevPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1A1A40),
                ),
                child: const Text("Back"),
              )
            else
              const SizedBox(width: 80), // spacer

            ElevatedButton(
              onPressed: () {
                if (selectedAnswers[index] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select an option!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (isLast) {
                  _handleSubmit();
                } else {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A40),
              ),
              child: Text(isLast ? "Submit" : "Next"),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
