/// Author: Rambo.Liu
/// Date: 2025/12/25 11:34
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sport_camera/pages/base_page.dart';
import 'package:sport_camera/pages/home/recommend_detail.dart';

import '../../provider/auth_model.dart';
import '../login_fail.dart';
import 'home_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class RecommendTabPage extends BasePage<AuthModel> {
  final String category;

  const RecommendTabPage({super.key, required this.category});

  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<AuthModel>(builder: (context, auth, child) {
  //       if(auth.isLoggedIn) {
  //         return MasonryGridView.count(
  //           padding: const EdgeInsets.all(12),
  //           crossAxisCount: 2,
  //           mainAxisSpacing: 12,
  //           crossAxisSpacing: 12,
  //           itemCount: 20,
  //           itemBuilder: (context, index) {
  //             return _buildItem(context, index);
  //           },
  //         );
  //       } else {
  //         return  Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               const Text('登录失败，请重试'),
  //               const SizedBox(height: 20),
  //               ElevatedButton(
  //                 onPressed: () {
  //                   // Go back to the login page
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('重试'),
  //               ),
  //             ],
  //           ),
  //         );
  //       }
  //   },);
  //
  //
  //
  // }

  @override
  RecommendTabPageState createState() => RecommendTabPageState();

}

class RecommendTabPageState extends BasePageState<RecommendTabPage, AuthModel> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildItem(BuildContext context, int index) {
    final double height = index.isEven ? 220 : 280;

    return InkWell(
      onTap: () {
        debugPrint('点击 ${widget.category} - $index');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecommendDetail()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
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
              child: const Center(child: Icon(Icons.image, size: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${widget.category} 内容标题 $index',
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

  @override
  Widget buildContent(BuildContext context) {
    if(model.isLoggedIn) {
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
    } else {
      return LoginFailPage();
    }
  }
}
