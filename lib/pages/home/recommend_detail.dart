import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '抖音视频播放器',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const RecommendDetail(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// 视频数据实体类
class VideoModel {
  final String url;
  final String user;
  final String desc;
  final String avatar;
  final String mode;
  final String cover;

  VideoModel({
    required this.url,
    required this.user,
    required this.desc,
    required this.avatar,
    required this.mode,
    required this.cover,
  });
}

// 模拟网络请求工具类
class VideoRequest {
  static List<VideoModel> videoUrls = [
    VideoModel(
      url: 'http://vjs.zencdn.net/v/oceans.mp4',
      user: '海洋',
      desc:  '陪我看世界吧，赴一场山海之约✨' ,
      avatar: 'https://picsum.photos/id/64/200/200',
      mode: '电影模式',
      cover: 'https://picsum.photos/id/640/360',
    ),
    VideoModel(
      url: 'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4',
      user: '西瓜视频DEMO',
      desc:  '来自西瓜的视频，娱乐剪辑' ,
      avatar: 'https://picsum.photos/id/64/200/200',
      mode: '电影模式',
      cover: 'https://picsum.photos/id/640/360',
    ),
    VideoModel(
      url: 'http://www.w3school.com.cn/example/html5/mov_bbb.mp4',
      user: '科学的尽头是什么',
      desc:  '陪我看世界吧，赴一场山海之约✨' ,
      avatar: 'https://picsum.photos/id/64/200/200',
      mode: '电影模式',
      cover: 'https://picsum.photos/id/640/360',
    ),
    VideoModel(
      url: 'https://www.w3schools.com/html/movie.mp4',
      user: '大灰熊',
      desc:  '陪我看世界吧，赴一场山海之约✨' ,
      avatar: 'https://picsum.photos/id/64/200/200',
      mode: '电影模式',
      cover: 'https://picsum.photos/id/640/360',
    ),
    VideoModel(
      url: 'https://media.w3.org/2010/05/sintel/trailer.mp4',
      user: '新闻直播',
      desc:  '陪我看世界吧，赴一场山海之约✨' ,
      avatar: 'https://picsum.photos/id/64/200/200',
      mode: '电影模式',
      cover: 'https://picsum.photos/id/640/360',
    ),
  ];
  static Future<List<VideoModel>> getVideoList(int page, int pageSize) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    List<VideoModel> videoList = [];
    int startIndex = (page - 1) * pageSize;
    int realLoadCount = pageSize;
    if (page == 3) realLoadCount = 2;
    if (page > 3) realLoadCount = 0;

    for (int i = 0; i < realLoadCount; i++) {
      int globalIndex = startIndex + i;
      videoList.add(VideoModel(
        url: 'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4',
        user: videoUrls[i].user,
        desc: globalIndex % 3 == 0 ? '陪我看世界吧，赴一场山海之约✨' : '翻过这座山，前路漫漫亦灿灿🌌',
        avatar: 'https://picsum.photos/id/64/200/200',
        mode: globalIndex % 2 == 0 ? '星空模式' : '电影模式',
        cover: 'https://picsum.photos/id/64/200/200',
      ));
    }
    return videoList;
  }
}

// ======================== 核心页面 - 终极根治 核心代码 ========================
class RecommendDetail extends StatefulWidget {
  const RecommendDetail({super.key});

  @override
  State<RecommendDetail> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<RecommendDetail> {
  final List<VideoModel> _videoList = [];
  int _currentPage = 1;
  final int _pageSize = 5;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPlayIndex = -1;

  late PageController _pageController;
  // 核心：三个数组与_videoList完全绑定，长度一致，一一对应，无任何错位可能
  final List<VideoPlayerController> _videoControllers = [];
  final List<bool> _isVideoInitialized = [];
  final List<bool> _isPlaying = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadMoreData();
  }

  // 分页加载数据
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      List<VideoModel> newVideos = await VideoRequest.getVideoList(_currentPage, _pageSize);
      setState(() {
        _videoList.addAll(newVideos);
        _hasMore = newVideos.length == _pageSize;
        _currentPage++;
        // 关键：数据加载后立即初始化控制器，与Item强绑定，无异步错位
        _initAllNewControllers(newVideos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // 核心修复：为新加载的视频【立即初始化控制器】，绑定到对应Item，无延迟
  void _initAllNewControllers(List<VideoModel> newVideos) {
    for (var video in newVideos) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(video.url));
      _videoControllers.add(controller);
      _isVideoInitialized.add(false);
      _isPlaying.add(false);

      // 初始化完成后，仅更新状态，不做任何页面跳转/重绘
      controller.initialize().then((_) {
        setState(() {
          int index = _videoControllers.indexOf(controller);
          if (index != -1) {
            _isVideoInitialized[index] = true;
            controller.setLooping(true);
            // 当前显示的Item，初始化完成后自动播放
            if (index == _currentPlayIndex) {
              controller.play();
              _isPlaying[index] = true;
            }
          }
        });
      });
    }
  }

  // 滑动切换视频
  void _handlePageChanged(int index) {
    // 暂停上一个视频
    if (_currentPlayIndex != -1 && _currentPlayIndex < _videoControllers.length) {
      _videoControllers[_currentPlayIndex].pause();
      setState(() => _isPlaying[_currentPlayIndex] = false);
    }

    // 播放当前视频（如果已初始化）
    _currentPlayIndex = index;
    if (_currentPlayIndex < _videoControllers.length && _isVideoInitialized[_currentPlayIndex]) {
      _videoControllers[_currentPlayIndex].play();
      setState(() => _isPlaying[_currentPlayIndex] = true);
    }

    // 触发加载更多
    if (_videoList.isNotEmpty && index == _videoList.length - 2 && _hasMore && !_isLoading) {
      _loadMoreData();
    }
  }

  // 点击切换播放/暂停
  void _togglePlayPause(int index) {
    if (index >= _videoControllers.length || !_isVideoInitialized[index]) return;
    setState(() {
      if (_isPlaying[index]) {
        _videoControllers[index].pause();
      } else {
        _videoControllers[index].play();
      }
      _isPlaying[index] = !_isPlaying[index];
    });
  }

  // 进度条拖动跳转
  void _seekToPosition(int index, double tapRatio) {
    if (index >= _videoControllers.length || !_isVideoInitialized[index]) return;
    Duration target = _videoControllers[index].value.duration * tapRatio;
    _videoControllers[index].seekTo(target);
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          leading: GestureDetector(onTap: ()=>Navigator.of(context).pop(),child: const Icon(Icons.arrow_back, color: Colors.white, size: 24)),
          actions: [
                  const Icon(Icons.crop_free, color: Colors.white, size: 24)
      ]),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 核心：垂直PageView，所有Item与数据强绑定
          _videoList.isNotEmpty
              ? PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _handlePageChanged,
            itemCount: _videoList.length,
            // 每个Item：绝对是同一个节点，封面/视频二选一，无分离
            itemBuilder: (context, index) => _buildVideoItem(index),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),


          // 加载中提示
          if (_isLoading)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                  child: const Text('正在加载数据', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),

          // 无更多数据提示
          if (!_hasMore && _videoList.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                  child: const Text('无更多数据', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ======================== ✅✅✅ 终极核心：单个Item构建 - 彻底根治分离问题 ✅✅✅ ========================
  Widget _buildVideoItem(int index) {
    final videoModel = _videoList[index];
    bool videoReady = _isVideoInitialized[index];
    bool playing = _isPlaying[index];
    VideoPlayerController controller = _videoControllers[index];

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      // 整个Item只有一个点击事件，只作用于视频/封面区域，右侧按钮无冲突
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _togglePlayPause(index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ========== 重中之重：封面 和 视频 绝对同位置、同层级、互斥显示 ==========
            // 规则：未初始化=封面，初始化=视频，永远二选一，同一个位置，无任何分离可能
            if (!videoReady)
              Image.network(
                videoModel.cover,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            else
              ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  //fit: BoxFit.cover,
                  child: VideoPlayer(controller),
                ),
              ),

            // 暂停时显示播放按钮 (仅视频加载完成后)
            if (videoReady && !playing)
              const Center(
                child: Icon(Icons.play_arrow, color: Colors.white, size: 80, ),
              ),

            // 右侧功能按钮区 - 独立点击，不触发播放暂停
            Positioned(
              right: 16,
              bottom: 140,
              child: Column(
                children: [
                  _buildIconBtn(Icons.favorite_border, '2', () => debugPrint('点赞')),
                  _buildIconBtn(Icons.chat_bubble_outline, '评论', () => debugPrint('评论')),
                  _buildIconBtn(Icons.bookmark_border, '收藏', () => debugPrint('收藏')),
                  _buildIconBtn(Icons.share, '分享', () => debugPrint('分享')),
                ],
              ),
            ),

            // 左下角用户信息
            Positioned(
              left: 16,
              bottom: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(videoModel.avatar), radius: 18),
                      const SizedBox(width: 12),
                      Text(videoModel.user, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('关注', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(videoModel.desc, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(videoModel.mode, style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 右下角 剪同款 按钮
            Positioned(
              right: 16,
              bottom: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(20)),
                child: const Text('剪同款', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),

            // 底部进度条 - 上移20像素 + 可拖动跳转
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: videoReady
                  ? GestureDetector(
                onTapDown: (details) {
                  double ratio = details.localPosition.dx / MediaQuery.of(context).size.width;
                  _seekToPosition(index, ratio);
                },
                child: Container(
                  height: 4,
                  width: double.infinity,
                  child: StreamBuilder(
                    stream: Stream.periodic(const Duration(milliseconds: 80)),
                    builder: (context, _) {
                      double playRatio = controller.value.position.inMilliseconds / controller.value.duration.inMilliseconds;
                      playRatio = playRatio.isNaN || playRatio > 1 ? 0 : playRatio;
                      double bufferRatio = controller.value.buffered.isNotEmpty
                          ? controller.value.buffered.last.end.inMilliseconds / controller.value.duration.inMilliseconds
                          : playRatio + 0.15;
                      bufferRatio = bufferRatio.isNaN || bufferRatio > 1 ? 1 : bufferRatio;
                      return Stack(fit: StackFit.expand, children: [
                        FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: bufferRatio, child: Container(color: Colors.yellow)),
                        FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: playRatio, child: Container(color: Colors.white)),
                      ]);
                    },
                  ),
                ),
              )
                  : const SizedBox(height: 4),
            ),
          ],
        ),
      ),
    );
  }

  // 右侧功能按钮
  Widget _buildIconBtn(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: Colors.white, size: 28), onPressed: onPressed),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 20),
      ],
    );
  }
}