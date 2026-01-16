import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/16 09:50
/// @Copyright by JYXC Since 2023
/// Description: 剪辑详细页面的模板组件
//
// void main() {
//   runApp(const MyApp());
// }
//
// /// =======================
// /// App
// /// =======================
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: EditTempleteDetail(),
//     );
//   }
// }

class EditTempleteDetail extends StatefulWidget {
  const EditTempleteDetail({super.key});
  @override
  State<EditTempleteDetail> createState() => _HomePageState();
}

class _HomePageState extends State<EditTempleteDetail> with TickerProviderStateMixin {
  late TabController _mainController;

  final imgs = [
    TempleteData(imageUrl: 'https://picsum.photos/id/10/800/300', title: '全景AI 战车', isTop: true, fragmentCount:1,width: 400, height: 200),
    TempleteData(imageUrl: 'https://picsum.photos/id/20/800/300', title: '全景摩托视角', isTop: false, fragmentCount:21,width: 800, height: 300),
    TempleteData(imageUrl: 'https://picsum.photos/id/30/800/300', title: '愿望语录', isTop: false, fragmentCount:21,width: 500, height: 300),
    TempleteData(imageUrl: 'https://picsum.photos/id/20/800/300', title: '全景摩托视角', isTop: false, fragmentCount:21,width: 500, height: 400),
    TempleteData(imageUrl: 'https://picsum.photos/id/20/800/300', title: '全景摩托视角', isTop: false, fragmentCount:21,width: 400, height: 400),
    TempleteData(imageUrl: 'https://picsum.photos/id/20/800/300', title: '全景摩托视角', isTop: false, fragmentCount:21,width: 300, height: 200),
    TempleteData(imageUrl: 'https://picsum.photos/id/20/800/300', title: '全景摩托视角', isTop: false, fragmentCount:21,width: 500, height: 300),

  ];

  late TempleteData curData = imgs[0];

  @override
  void initState() {
    super.initState();
    _mainController = TabController(length: imgs.length, vsync: this);
    _mainController.addListener(() {
      if (_mainController.indexIsChanging) {
        return;
      }
      final mainTabIndex = _mainController.index;
      setState(() {
        curData = imgs[mainTabIndex];
      });
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          curData.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "作者: 菜菜",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.content_cut, size: 12, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '片段 ${curData.fragmentCount}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: curData.width / curData.height,
                              child: Image.network(
                                curData.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildMainImagePlaceholder(isError: true),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return _buildMainImagePlaceholder();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '使用模板',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '限免10次',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        '更多模板',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        controller: _mainController,
                        indicatorColor: Colors.transparent,
                        indicator: const BoxDecoration(),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        tabs: imgs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tmpData = entry.value;
                          final isSelected = _mainController.index == index;
                          return Tab(
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.yellow, width: 2),
                                    )
                                  : null,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: Image.network(
                                  tmpData.imageUrl,
                                  width: 100,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildThumbnailPlaceholder(isError: true),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return _buildThumbnailPlaceholder();
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainImagePlaceholder({bool isError = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      child: Center(
        child: Icon(
          isError ? Icons.error_outline : Icons.image,
          color: Colors.white30,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder({bool isError = false}) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Center(
        child: Icon(
          isError ? Icons.error_outline : Icons.image,
          color: Colors.white30,
          size: 24,
        ),
      ),
    );
  }
}

class TempleteData {
  final String imageUrl;
  final String title;
  final bool isTop;
  final int fragmentCount;
  final int width;
  final int height;

  TempleteData({
    required this.imageUrl,
    required this.title,
    required this.isTop,
    required this.fragmentCount,
    required this.width,
    required this.height,

  });

}
