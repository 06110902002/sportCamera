/// Author: Rambo.Liu
/// Date: 2026/1/16 14:07
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomBottomBar(),
    );
  }
}

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({Key? key}) : super(key: key);

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int _currentIndex = 2;

  final List<String> titles = ['首页', '相册', '相机', '剪辑', '我的'];
  final List<IconData> icons = [
    Icons.home_outlined,
    Icons.image_outlined,
    Icons.camera_alt_outlined, // 中间项图标
    Icons.cut_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(child: Container()),
            // 自定义底部导航栏
            Container(
              height: 70,
              margin:  const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(0, _currentIndex == 0),
                  _buildTab(1, _currentIndex == 1),

                  // 中间突出按钮
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 2;
                        });
                      },
                      backgroundColor: _currentIndex == 2 ? Colors.yellow : Colors.grey[300],
                      elevation: 0,
                      child: Icon(
                        Icons.camera_alt,
                        color: _currentIndex == 2 ? Colors.black : Colors.grey[700],
                        size: 28,
                      ),
                    ),
                  ),

                  _buildTab(3, _currentIndex == 3),
                  _buildTab(4, _currentIndex == 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[index],
              size: 20,
              color: isSelected ? Colors.black : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              titles[index],
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
