import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Shows a custom error dialog with MoodyLune theme.
void showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            color: Color(0xFFA29BFE),
          ),
          const SizedBox(width: 10),
          const Text(
            'Oops!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitPulse(
            color: Color(0xFFA29BFE),
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'OK',
            style: TextStyle(
              color: Color(0xFFA29BFE),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Future<void> showCounsellorChoiceDialog(
    BuildContext context,
    VoidCallback onGeminiSelected,
    ) {
  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFF1A1A40),
        title: const Text(
          "Talk to someone?",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onGeminiSelected();
              },
              icon: Icon(CupertinoIcons.exclamationmark_bubble_fill),
              label: Text("AI Counsellor"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A40),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: null, // disabled
              icon: Icon(CupertinoIcons.person_crop_square),
              label: Text("Real Counsellor (coming soon)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade600,
                disabledForegroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: Icon(CupertinoIcons.xmark),
              label: Text("Nahh I'm good"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A40),
              ),
            ),
          ],
        ),
      );
    },
  );
}