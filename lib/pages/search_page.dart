/// Author: Rambo.Liu
/// Date: 2026/1/12 17:18
/// @Copyright by JYXC Since 2023
/// Description: 搜索页面
import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SearchPage(),
//     );
//   }
// }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  /// 搜索源数据
  final List<String> _allContents = [
    '樱粉滤镜，把日常调到浪漫频道',
    '4大运镜，普通场景变电影',
    '6个必备的丝滑转场技巧',
    '三步搞定爆火的希区柯克运镜',
    '抛上天，get小行星转场',
    '简单两步操作，实现旋缩跟随',
    '5种创意运镜，让镜头会说话',
    '拍出演唱会梦幻镜头',
    '机车玩家私藏！仪表水印+多控制方式超实用',
    '用骑行尾杆get博主同款创意拍摄视角',
  ];

  /// 热门教程
  List<String> hotList = [
    '添加第三方仪表盘',
    'GPS 图传遥控器',
    '骑行玩法',
    '移动花海',
  ];

  /// 搜索历史
  List<String> historyList = [
    '抛上天，get小行星转场',
    '移动花海',
    '骑行玩法',
    'GPS 图传遥控器',
  ];

  bool historyExpanded = false;

  List<String> searchResult = [];

  void _onSearchChanged(String value) {
    setState(() {
      searchResult =
          _allContents.where((e) => e.contains(value)).toList();
    });
  }

  void _addToHistory(String item) {
    setState(() {
      historyList.remove(item);
      historyList.insert(0, item);
    });
  }

  void _onHotClick(String item) {
    setState(() {
      hotList.remove(item);
      hotList.insert(0, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: '搜索教程',
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.clear();
              Navigator.pop(context);
              setState(() {
                searchResult.clear();
              });
            },
            child: const Text('取消'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          children: [
            if (_controller.text.isEmpty) _buildHistorySection(),
            if (_controller.text.isEmpty) _buildHotSection(),
            if (_controller.text.isNotEmpty)
              ...searchResult.map(
                    (item) => ListTile(
                  title: Text(item),
                  onTap: () {
                    debugPrint('搜索点击: $item');
                    _addToHistory(item);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 历史搜索
  Widget _buildHistorySection() {
    final List<String> displayList = historyExpanded
        ? historyList
        : historyList.take(3).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '历史搜索',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: historyList.isEmpty
                    ? null
                    : () {
                  setState(() {
                    historyList.clear();
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  historyExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: historyList.length <= 3
                    ? null
                    : () {
                  setState(() {
                    historyExpanded = !historyExpanded;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (historyList.isEmpty)
            const Text(
              '暂无搜索记录',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: displayList
                  .map(
                    (e) => ActionChip(
                  label: Text(e),
                  onPressed: () {
                    _controller.text = e;
                    _onSearchChanged(e);
                  },
                ),
              )
                  .toList(),
            ),
        ],
      ),
    );
  }

  /// 热门教程
  Widget _buildHotSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门教程',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hotList.length,
            itemBuilder: (context, index) {
              final item = hotList[index];
              final bool highlight = index < 3;
              return ListTile(
                leading: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: highlight ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(item),
                trailing: highlight
                    ? const Icon(
                  Icons.local_fire_department,
                  color: Colors.red,
                )
                    : null,
                onTap: () => _onHotClick(item),
              );
            },
          ),
        ],
      ),
    );
  }
}
