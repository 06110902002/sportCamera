import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AIEffectList(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class AIEffectList extends StatelessWidget {
  const AIEffectList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI特效')),
      body: ListView.builder(
        itemCount: effects.length,
        itemBuilder: (context, index) {
          final item = effects[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 背景图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200, // 固定高度
                    ),
                  ),
                  // 左下角文字
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 示例数据：使用本地 assets 图片
final List<EffectItem> effects = [
  EffectItem(
    image: 'https://picsum.photos/id/20/800/300',
    title: '魔法天空',
    subtitle: '仅适用于X5/4/3/2, ONE RS/R 相机拍摄的全景素材',
  ),
  EffectItem(
    image: 'https://picsum.photos/id/10/800/300',
    title: 'AI魔术师',
    subtitle: '适用于所有机型',
  ),
  EffectItem(
    image: 'https://picsum.photos/id/70/800/300',
    title: '未来城市',
    subtitle: '支持HDR与动态模糊',
  ),
];

class EffectItem {
  final String image;
  final String title;
  final String subtitle;

  EffectItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
