import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/16 15:02
/// @Copyright by JYXC Since 2023
/// Description: 小红点组件
/// 0 = hidden, 1 = red dot, >1 = count in a badge. >99 show 99+
// Custom widget for the 'My' page icon to handle network image, placeholder, and notification dot.
class RedPoint extends StatelessWidget {
  final int notificationCount;
  final bool isSelected;

  const RedPoint({
    required this.notificationCount,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // A sample URL for the user's avatar.
    const String avatarUrl = 'https://picsum.photos/id/1005/200/200';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.network(
              avatarUrl,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                // Show a default icon while loading.
                return Icon(
                  Icons.person,
                  color: isSelected ? Colors.orange : Colors.grey,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                // Show a default icon on error.
                return Icon(
                  Icons.person,
                  color: isSelected ? Colors.orange : Colors.grey,
                );
              },
            ),
          ),
        ),
        // Display a red dot or a count badge for notifications.
        if (notificationCount > 0)
          Positioned(
            top: -3,
            right: -5,
            child: notificationCount == 1
            // Show a simple dot for a single notification.
                ? Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            )
            // Show a badge with the count for multiple notifications.
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
