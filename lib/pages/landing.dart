import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/emotions_survey.dart';
import '../widgets/mood_picker.dart';
import 'mood.dart';
import 'old_journal.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? username;
  String? profileUrl;
  String? dailyVerse;
  String? onThisDayJournalTitle;
  String? onThisDayJournalContent;
  List<Map<String, dynamic>> recentJournals = [];
  String moonPhaseText = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadDailyVerse();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');

    if (storedUsername != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(storedUsername)
          .get();

      setState(() {
        username = storedUsername;
        profileUrl = doc.data()?['profile_url'] as String?;
      });

      await loadOnThisDayJournal(storedUsername);
      await loadRecentJournals(storedUsername);
    }
  }

  Future<void> loadDailyVerse() async {
    // For now, just random hardcoded. Could fetch from Firestore.
    final verses = [
      "God is our refuge and strength. – Psalm 46:1",
      "Even the darkest night will end and the sun will rise. – Victor Hugo",
      "Be still, and know that I am God. – Psalm 46:10",
      "The Lord will fight for you; you need only to be still. – Exodus 14:14",
    ];
    verses.shuffle();
    setState(() {
      dailyVerse = verses.first;
    });
  }

  Future<void> loadOnThisDayJournal(String username) async {
    final now = DateTime.now();
    final dateTitle = generateTitle(now);

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("journals")
        .doc(dateTitle)
        .get();

    if (doc.exists) {
      setState(() {
        onThisDayJournalTitle = doc.id;
        onThisDayJournalContent = doc.get("content");
      });
    }
  }

  Future<void> loadRecentJournals(String username) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(username)
        .collection("journals")
        .orderBy("created_at", descending: true)
        .limit(5)
        .get();

    setState(() {
      recentJournals = snapshot.docs
          .map((doc) => {"title": doc.id, "content": doc.get("content") ?? ""})
          .toList();
    });
  }

  String generateTitle(DateTime now) {
    final day = now.day;
    final month = DateFormat.MMMM().format(now);
    final year = now.year;
    final suffix = getDaySuffix(day);
    return "$day$suffix $month, $year";
  }

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return "th";
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

  void showMoodModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoodPickerSheet(username: username!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (username == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome tile
            _buildWelcomeTile(),

            const SizedBox(height: 30),

            if (dailyVerse != null) _buildVerseTile(),

            const SizedBox(height: 50),
            Divider(height: 1),
            _buildMoodStats(),
            Divider(height: 1),
            const SizedBox(height: 50),

            if (onThisDayJournalTitle != null) _buildOnThisDay(),

            const SizedBox(height: 40),

            _buildAIChatPrompt(username: username!),

            const SizedBox(height: 40),
            Divider(height: 1),
            const SizedBox(height: 10),
            _buildRecentJournals(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeTile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        color: const Color(0xFF4B4376),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hii, $username',
                    style: GoogleFonts.pacifico(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EmotionSurveySheet(username: username!),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF1A1A40),
                    ),
                    child: const Text('Record New Emotions'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            profileUrl != null && profileUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(profileUrl!),
                  )
                : CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: const Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4B4376),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dailyVerse!,
        style: GoogleFonts.twinkleStar(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none, // <--- this
        ),
      ),
    );
  }

  Widget _buildMoodStats() {
    return GestureDetector(
      onTap: showMoodModal,
      child: Container(
        height: 80, // Increased height
        decoration: BoxDecoration(
          color: const Color(0xFF4B4376),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Tap here to record your mood with MoodyLune!",
                  style: GoogleFonts.twinkleStar(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Icon(
                CupertinoIcons.hand_draw_fill,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnThisDay() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OldJournalPage(
              journalTitle: onThisDayJournalTitle!,
              content: onThisDayJournalContent ?? "",
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0x3B3660FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "On This Day:",
              style: GoogleFonts.twinkleStar(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none, // <--- this
              ),
            ),
            const SizedBox(height: 8),
            Text(
              onThisDayJournalContent ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.twinkleStar(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none, // <--- this
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIChatPrompt({required String username}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4B4376),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Hey! Wanna chat with MoodyLune AI?",
              style: GoogleFonts.twinkleStar(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none, // <--- this
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoodsPage(
                    username:
                        username, // ← pass the current user's username here
                    openAsChat: true,
                  ),
                ),
              );
            },
            child: Text("Chat Now"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJournals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Journals",
          style: GoogleFonts.pacifico(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none, // <--- this
          ),
        ),
        const SizedBox(height: 12),
        ...recentJournals.map(
          (journal) => Card(
            color: Color(0xFF2B2B52),
            child: ListTile(
              title: Text(
                journal["title"],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                journal["content"].length > 50
                    ? "${journal["content"].substring(0, 50)}..."
                    : journal["content"],
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OldJournalPage(
                      journalTitle: journal["title"],
                      content: journal["content"],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
