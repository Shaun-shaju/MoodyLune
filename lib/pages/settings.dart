import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'login.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

class SettingsPage extends StatefulWidget {
  final String username;

  const SettingsPage({super.key, required this.username});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? profileUrl;
  String? name;
  String? dob;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.username)
        .get();

    if (doc.exists) {
      setState(() {
        profileUrl = doc["profile_url"];
        name = doc["name"];
        dob = doc.data()?["dob"];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateField(String field, String value) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.username)
        .update({field: value});
    await _loadUserProfile();
  }

  Future<void> _changePassword() async {
    // Show a dialog to get the new password
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Password"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "New Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );

    if (newPassword != null && newPassword.isNotEmpty) {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password updated.")));
    }
  }

  Future<void> _changeName() async {
    final controller = TextEditingController(text: name ?? "");
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Name"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: "Your Name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _updateField("name", newName);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Name updated.")));
    }
  }

  Future<void> _changeDOB() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      await _updateField("dob", "${selectedDate.toLocal()}".split(' ')[0]);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Date of birth updated.")));
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Account"),
        content: Text(
          "Are you sure you want to delete your account? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Delete Firestore data
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.username)
          .delete();

      // Delete FirebaseAuth user
      await FirebaseAuth.instance.currentUser?.delete();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Log Out"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Or any color you prefer
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Widget _buildRow({
    required IconData icon,
    required String title,
    String? subtitle,
    bool showDot = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(icon, color: Colors.blueGrey),
          if (showDot)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(title, style: TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey))
          : null,
      trailing: Icon(CupertinoIcons.forward, size: 18),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Settings")),
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          Container(
            color: Colors.black12,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                profileUrl != null && profileUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(profileUrl!),
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade400,
                        child: Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                SizedBox(height: 10),
                Text(
                  name ?? "No name set",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? "",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          _buildRow(
            icon: CupertinoIcons.person,
            title: "Change Name",
            subtitle: name,
            showDot: (name == null || name!.isEmpty),
            onTap: _changeName,
          ),
          _buildRow(
            icon: CupertinoIcons.photo,
            title: "Change Profile Photo",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Change photo coming soon!")),
              );
            },
            // onTap: () async {
            //   final picker = ImagePicker();
            //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
            //
            //   if (pickedFile != null) {
            //     final file = File(pickedFile.path);
            //
            //     // Upload to Firebase Storage
            //     final storageRef = FirebaseStorage.instance
            //         .ref()
            //         .child('profile_photos/${widget.username}.jpg');
            //
            //     await storageRef.putFile(file);
            //
            //     final downloadUrl = await storageRef.getDownloadURL();
            //
            //     // Save URL to Firestore
            //     await FirebaseFirestore.instance
            //         .collection("users")
            //         .doc(widget.username)
            //         .update({
            //       "profile_url": downloadUrl,
            //     });
            //
            //     await _loadUserProfile();
            //
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(content: Text("Profile photo updated!")),
            //     );
            //   }
            // },
          ),
          _buildRow(
            icon: CupertinoIcons.lock,
            title: "Change Password",
            onTap: _changePassword,
          ),
          _buildRow(
            icon: CupertinoIcons.calendar,
            title: "Add Date of Birth",
            subtitle: dob,
            showDot: dob == null,
            onTap: _changeDOB,
          ),
          ListTile(
            leading: Icon(CupertinoIcons.lock_circle_fill, color: Colors.blue),
            title: Text("Log Out", style: TextStyle(color: Colors.blue)),
            onTap: _logout,
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(CupertinoIcons.delete, color: Colors.red),
            title: Text("Delete Account", style: TextStyle(color: Colors.red)),
            onTap: _deleteAccount,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Use url_launcher if you want to open the link in the browser
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Visit Shaun's Website"),
                      content: Text(
                        "Open shaun-shaju.github.io in your browser?",
                      ),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: Text("Open"),
                          onPressed: () {
                            Navigator.pop(context);
                            // open the URL
                            // For full functionality, add `url_launcher` package:
                            // launchUrl(Uri.parse('https://shaun-shaju.github.io'));
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  "Made with love ❤️ by S. Shaun Benedict",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
