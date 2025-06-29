import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moodylune/pages/journal.dart';
import 'package:moodylune/pages/landing.dart';
import 'package:moodylune/pages/mood.dart';
import 'package:moodylune/pages/settings.dart';

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.darkBackgroundGray,
        activeColor: CupertinoColors.systemGrey4,
        inactiveColor: CupertinoColors.inactiveGray,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_alt_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_circle_fill),
            label: 'Counsel',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book_circle_fill),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        late final Widget page;

        switch (index) {
          case 0:
            page = const HomeTab();
            break;
          case 1:
            page = MoodsPage(
              username: username, // ← pass the current user's username here
              openAsChat: true,
            );
            break;
          case 2:
            page = JournalPage(username: username);
            break;
          case 3:
            page = SettingsPage(username: username);
            break;
          default:
            page = Container();
        }

        return CupertinoPageScaffold(
          backgroundColor: Color(0xFF1A1A40),
          navigationBar: CupertinoNavigationBar(
            backgroundColor: Color(0xFF1A1A40),
            middle: Text(
              _getTitle(index),
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
            automaticallyImplyLeading: false, // Hide the back button
          ),
          child: SafeArea(child: page),
        );
      },
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Moods";
      case 2:
        return "Journal";
      case 3:
        return "Settings";
      default:
        return "";
    }
  }
}
