/// Author: Rambo.Liu
/// Date: 2025/12/25 11:21
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCategoryTabs(),
          const Spacer(),
          _buildEmptyState(),
          const Spacer(),
          _buildBottomSwitcher(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      titleSpacing: 16,
      title: const Row(
        children: [
          Text(
            '相机文件',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Text(
            '已下载',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: const [
        Icon(Icons.swap_vert, color: Colors.white),
        SizedBox(width: 16),
        Icon(Icons.check_circle_outline, color: Colors.white),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    final tabs = ['回忆', '全部', '收藏', '视频', '照片', '实况'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final selected = index == 1;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (selected)
                Container(
                  width: 24,
                  height: 3,
                  color: Colors.yellow,
                ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemCount: tabs.length,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const Icon(Icons.inbox, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          '没有文件，请连接相机',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '点击连接相机',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSwitcher() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 80),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.grid_view, color: Colors.white54),
          Icon(Icons.calendar_month, color: Colors.white54),
        ],
      ),
    );
  }
}

