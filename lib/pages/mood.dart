import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodylune/pages/home.dart';

class MoodsPage extends StatefulWidget {
  final String username;
  final bool openAsChat;

  const MoodsPage({
    super.key,
    required this.username,
    this.openAsChat = false,
  });

  @override
  State<MoodsPage> createState() => _MoodsPageState();
}

class _MoodsPageState extends State<MoodsPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  late final GenerativeModel _model;

  List<Map<String, String>> messages = [];

  late final String docId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";
    docId = date;
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash', systemInstruction: Content.text("You are MoodyLune AI, a kind and caring virtual mental health companion. Your mission is to gently support users who may be struggling with emotions, anxiety, stress, sadness, or any mental health challenge. Always speak in a warm, encouraging, and compassionate tone. Keep your responses concise but empathetic, avoiding long essays unless the user asks for more detail. If a user shares something serious or mentions harming themselves or others, gently encourage them to seek help from a trusted person, mental health professional, or emergency services, but do not attempt to diagnose or treat. Avoid giving medical, legal, or financial advice. Instead, provide emotional support, calming words, and practical self-care suggestions. Use simple, friendly language suitable for teens and young adults. Add a sprinkle of positivity, hope, and reassurance to every reply, and remind users they are not alone. When appropriate, suggest small mood-lifting activities like journaling, deep breathing, listening to music, or taking a short walk. Always protect user privacy and do not share personal information. Never generate inappropriate or harmful content. Your personality is gentle, friendly, and a bit whimsical, like a wise companion under the moonlight. Keep the output responses very small as possible as a teenage girl. Deny all kind of advances. Dont use Markdown as text.. just use the normal text.")
    );
    _loadExistingMessages();
  }

  Future<void> _loadExistingMessages() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.username)
        .collection("chats")
        .doc(docId)
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final List<dynamic> rawMessages = data["messages"] ?? [];
      final loadedMessages = rawMessages.map((msg) {
        return Map<String, String>.from(msg as Map);
      }).toList();
      setState(() {
        messages = loadedMessages;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToBottom();
    }
  }

  Future<void> _saveMessages() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.username)
        .collection("chats")
        .doc(docId)
        .set({
      "messages": messages,
    });
  }

  Future<void> _sendMessage() async {
    final userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      _isLoading = true;
      messages.add({"role": "user", "text": userInput});
      _controller.clear();
    });

    _scrollToBottom();
    await _saveMessages();

    try {
      final prompt = [Content.text(userInput)];
      final response = await _model.generateContent(prompt);
      final assistantReply = response.text ?? "Sorry, I didn’t get that.";

      setState(() {
        messages.add({"role": "assistant", "text": assistantReply});
      });

      _scrollToBottom();
      await _saveMessages();
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "text": "Error talking to MoodyLune AI: $e"
        });
      });
      _scrollToBottom();
      await _saveMessages();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(
              username: widget.username,
            )));
          },
        ),
        title: Text("Chat with MoodyLune AI", style: GoogleFonts.twinkleStar(color: Colors.white, fontSize: 20)),
        backgroundColor: Color(0xFF210F37),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg["role"] == "user";

                return Container(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Color(0xFF98A1BC)
                          : Color(0xFF393E46),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: GoogleFonts.twinkleStar(
                        color: isUser ? Colors.black87 : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white10,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.twinkleStar(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your feelings...",
                      hintStyle: TextStyle(color: Colors.white60),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(CupertinoIcons.paperplane_fill, color: Color(0xFF98A1BC)),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
