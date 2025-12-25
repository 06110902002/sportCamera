/// Author: Rambo.Liu
/// Date: 2025/12/25 11:34
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'home_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RecommendTabPage extends StatelessWidget {
  final String category;

  const RecommendTabPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(12),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: 20,
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final double height = index.isEven ? 220 : 280;

    return InkWell(
      onTap: () {
        debugPrint('点击 $category - $index');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域（高度不一致 → 瀑布流效果）
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '$category 内容标题 $index',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



