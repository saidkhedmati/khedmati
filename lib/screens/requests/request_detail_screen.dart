import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/service_request_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/online_dot.dart';
import '../messages/chat_screen.dart';

class RequestDetailScreen extends StatelessWidget {
  final ServiceRequestModel request;
  const RequestDetailScreen({super.key, required this.request});

  Future<void> _startChat(BuildContext context) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    if (myUid == request.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا الطلب ديالك نتا')),
      );
      return;
    }

    final chatId = await FirestoreService().getOrCreateChat(
      requestId: request.id,
      requestTitle: request.title,
      myUid: myUid,
      otherUid: request.userId,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            title: request.title,
            otherUid: request.userId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AvatarWithPresence(
                        uid: request.userId,
                        dotSize: 12,
                        avatar: CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          backgroundImage: request.userPhotoUrl != null
                              ? NetworkImage(request.userPhotoUrl!)
                              : null,
                          child: request.userPhotoUrl == null
                              ? const Icon(Icons.person, color: AppColors.primaryBlue)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(request.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.border),
                  _row(Icons.location_city_outlined, request.city),
                  _row(Icons.access_time,
                      timeago.format(request.createdAt, locale: 'ar')),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(request.description,
                        style: const TextStyle(fontSize: 13.5, height: 1.6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _startChat(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('بدء محادثة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}
