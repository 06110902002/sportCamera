/// Author: Rambo.Liu
/// Date: 2026/1/16 17:04
/// @Copyright by JYXC Since 2023
/// Description:
/// 支持加载网络图片（包括 GIF）,自定义loading， 视图 error 视图
import 'package:flutter/material.dart';

/// 高性能网络图片组件，支持自定义 loading/error，无闪烁，无状态
class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double borderRadius;
  final Widget Function(BuildContext context, String url)? loadingBuilder;
  final Widget Function(BuildContext context, String url, Object error)?
  errorBuilder;
  final BoxFit? fit;

  const CustomNetworkImage({
    Key? key,
    required this.imageUrl,
    this.borderRadius = 0.0,
    this.loadingBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          // 图片已加载完成
          if (loadingProgress == null) {
            return child;
          }

          // 自定义 loading
          if (loadingBuilder != null) {
            return loadingBuilder!(context, imageUrl);
          }

          // ✅ 默认 loading：透明背景 + 居中指示器（不改变布局）
          // 因为父级已提供尺寸（如 SizedBox），此处只需填充内容
          return Container(
            color: Colors.transparent, // 关键：不改变背景，避免闪烁
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (errorBuilder != null) {
            return errorBuilder!(context, imageUrl, error);
          }

          // ✅ 默认错误：同样保持透明背景，仅显示图标
          return Container(
            color: Colors.transparent,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 48,
              ),
            ),
          );
        },
        gaplessPlayback: true,
      ),
    );
  }
}

// 🚀 主应用入口

// 👆 上面的 CustomNetworkImage 放在这里

// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('优化版图片加载')),
//         body: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               // 1. 默认行为（带圆角）
//               SizedBox(
//                 height: 120,
//                 child: CustomNetworkImage(
//                   imageUrl: 'https://picsum.photos/300/200?random=1',
//                   borderRadius: 16,
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // 2. 自定义 loading 和 error
//               SizedBox(
//                 height: 120,
//                 child: CustomNetworkImage(
//                   imageUrl: 'https://example.com/404.jpg', // 无效链接
//                   borderRadius: 12,
//                   loadingBuilder: (context, url) =>
//                   const Center(child: Text('努力加载中...')),
//                   errorBuilder: (context, url, error) =>
//                   const Center(child: Text('❌ 图片挂了')),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // 3. GIF 动图（圆形）
//               SizedBox(
//                 height: 120,
//                 child: CustomNetworkImage(
//                   imageUrl:
//                   'https://media.giphy.com/media/3o7TKsQ8UQ4l4LhG2c/giphy.gif',
//                   borderRadius: 60, // 圆形
//                   loadingBuilder: (context, url) =>
//                   const Center(child: CircularProgressIndicator()),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
