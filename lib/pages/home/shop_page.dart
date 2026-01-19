/// Author: Rambo.Liu
/// Date: 2025/12/25 11:26
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

import '../../widget/custom_network_image.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topOffset = MediaQuery.of(context).padding.top;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        //home_page.dart 中设置了extendBodyBehindAppBar: curSelectIdx == 2,
        // 防止home_page.dart tab 切换时没有设置extendBodyBehindAppBar属于导致页面跳变的bug
        // 用于占位
        SizedBox(height: topOffset),
        _buildBanner(),
        const SizedBox(height: 24),
        _buildSectionTitle('消费级产品'),
        const SizedBox(height: 16),
        _buildProductGrid(),
      ],
    );
  }

  /// 顶部 Banner
  Widget _buildBanner() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Colors.black, Colors.black87]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '影石 Insta360 X5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '昼夜随行，视界由你',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '立即购买',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.camera_alt, size: 72, color: Colors.white30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// 商品 Grid（2 列）
  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (_, index) {
        return _buildProductItem(
          name: index.isEven ? '影石 Insta360 X4 Air' : '影石 Insta360 Wave',
          price: index.isEven ? '¥2,399 起' : '¥2,198 起',
        );
      },
    );
  }

  Widget _buildProductItem({required String name, required String price}) {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: CustomNetworkImage(
                    imageUrl: 'https://picsum.photos/300/200?random=1',
                    borderRadius: 16,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(price, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
