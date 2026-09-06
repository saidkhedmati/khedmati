import 'package:flutter/material.dart';
import '../services/presence_service.dart';
import '../theme/app_theme.dart';

/// نقطة صفراء/خضراء صغيرة كتبان فوق أي صورة بروفيل، كتبدل بشكل حي
/// (Stream) حسب واش هاداك الشخص فاتح التطبيق دابا ولا لا.
class OnlineDot extends StatelessWidget {
  final String uid;
  final double size;

  const OnlineDot({super.key, required this.uid, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: PresenceService().streamOnlineStatus(uid),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;
        if (!isOnline) return const SizedBox.shrink();
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      },
    );
  }
}

/// كيلف أي صورة بروفيل ويزيد ليها النقطة فالركن السفلي
class AvatarWithPresence extends StatelessWidget {
  final Widget avatar;
  final String uid;
  final double dotSize;

  const AvatarWithPresence({
    super.key,
    required this.avatar,
    required this.uid,
    this.dotSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          bottom: 0,
          right: 0,
          child: OnlineDot(uid: uid, size: dotSize),
        ),
      ],
    );
  }
}
