/// Author: Rambo.Liu
/// Date: 2026/1/4 15:44
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'package:flutter/material.dart';

//模拟自适应高度的网格布局
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexible Grid Layout',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 模拟数据列表
  final List<FeedItem> _items = [
    FeedItem(
      imageUrl: 'https://picsum.photos/300/200?random=1',
      title: 'Item 1',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/300/200?random=2',
      title: 'Item 2',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/300/200?random=3',
      title: 'Item 3',
    ),
    FeedItem(
      imageUrl: 'https://picsum.photos/300/200?random=4',
      title: 'Item 4',
    ),
    //FeedItem(imageUrl: 'https://via.placeholder.com/400x300/FF00FF/FFFFFF?text=Item5', title: 'Item 5'),
    // 取消下面的注释可以测试内容不足时的收缩效果
    // FeedItem(imageUrl: 'https://via.placeholder.com/400x300/00FFFF/000000?text=Item6', title: 'Item 6'),
  ];

  // 设定的最大高度
  static const double _maxHeight = 540.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自适应网格布局')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('下面是自适应高度的网格：'),
            const SizedBox(height: 10),
            // 核心布局部分
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              // 使用 CustomScrollView 替代之前的复杂嵌套
              child: CustomScrollView(
                // shrinkWrap: true 是关键！它让 CustomScrollView 的高度由其内容决定。
                shrinkWrap: true,
                // 只在内容超过 _maxHeight 时才显示滚动条
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // 使用 SliverToBoxAdapter 包裹 ConstrainedBox
                  SliverToBoxAdapter(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: _maxHeight),
                      // 在 ConstrainedBox 内部使用 GridView
                      child: GridView.builder(
                        // 同样需要 shrinkWrap: true
                        shrinkWrap: true,
                        // 因为父级是可滚动的，所以这里禁用自身的滚动
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8.0), // 网格内边距
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              childAspectRatio: 1.0, // 可以根据需要调整
                            ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return _FeedCard(item: _items[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('网格下方的其他内容'),
          ],
        ),
      ),
    );
  }
}

// 数据模型 (保持不变)
class FeedItem {
  final String imageUrl;
  final String title;

  FeedItem({required this.imageUrl, required this.title});
}

// 自定义卡片组件 (保持不变)
class _FeedCard extends StatelessWidget {
  final FeedItem item;

  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Image.network(
            item.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
