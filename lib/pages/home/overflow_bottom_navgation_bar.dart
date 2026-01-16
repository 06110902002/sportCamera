/// Author: Rambo.Liu
/// Date: 2026/1/16 13:57
/// @Copyright by JYXC Since 2023
/// Description: 凸出的底部导航栏
import 'package:flutter/material.dart';
import 'package:sport_camera/pages/clip_page.dart';
import 'package:sport_camera/pages/home/edit_page.dart';

import '../album_page.dart';
import '../easy_refresh_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        splashColor: Colors.transparent, // Optional: disable splash globally for InkWell
        highlightColor: Colors.transparent, // Optional: disable highlight globally for InkWell
      ),
      home: const MainTabPage(),
    );
  }
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;
  // This integer controls the notification badge on the 'My' tab.
  // 0 = hidden, 1 = red dot, >1 = count in a badge.
  int _myPageNotificationCount = 10;

  late final List<Widget> _pages = [
    const HomePage(),
    const AlbumPage(
      topTabs: ['相机文件', '已下载'],
      subTabs: ['回忆', '全部', '收藏', '视频', '照片', '实况'],
    ),
    ClipPage(), // 相机
    const EditPage(), // 剪辑
    const Placeholder(), // 我的
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body remains the same, showing the selected page.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // The FAB is now our central camera button.
      floatingActionButton: CircleAvatar(
        radius: 29, // You can now change this radius without breaking the layout.
        backgroundColor: Colors.yellow,
        child: IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.black, size: 24),
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // We use BottomAppBar to create a bar with a notch for the FAB.
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0, // The gap between the FAB and the bar.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(icon: Icons.home_outlined, label: '首页', index: 0),
            _buildNavItem(icon: Icons.photo_library_outlined, label: '相册', index: 1),
            // This is a placeholder that creates the space for the FAB.
            const SizedBox(width: 48),
            _buildNavItem(icon: Icons.cut, label: '剪辑', index: 3),
            // The 'My' page item is built separately to use the custom _MyPageIcon.
            _buildMyPageNavItem(index: 4),
          ],
        ),
      ),
    );
  }

  /// A helper method to build the standard navigation items.
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Colors.orange : Colors.grey;

    return InkWell(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0), // Adjust vertical padding for alignment
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  /// A specific helper for the 'My' page item which has a network image icon.
  Widget _buildMyPageNavItem({required int index}) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() {
        _currentIndex = index;
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MyPageIcon(
              notificationCount: _myPageNotificationCount,
              isSelected: isSelected,
            ),
            const SizedBox(height: 4),
            Text('我的',
                style: TextStyle(
                    fontSize: 12, color: isSelected ? Colors.orange : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Custom widget for the 'My' page icon to handle network image, placeholder, and notification dot.
class _MyPageIcon extends StatelessWidget {
  final int notificationCount;
  final bool isSelected;

  const _MyPageIcon({
    required this.notificationCount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // A sample URL for the user's avatar.
    const String avatarUrl = 'https://picsum.photos/id/1005/200/200';
    final color = isSelected ? Colors.orange : Colors.grey;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 24, // Standard icon width
          height: 24, // Standard icon height
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.network(
                avatarUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Icon(Icons.person, color: color);
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: color);
                },
              ),
            ),
          ),
        ),
        // Display a red dot or a count badge for notifications.
        if (notificationCount > 0)
          Positioned(
            top: -3,
            right: -5,
            child: notificationCount == 1
                ? Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

