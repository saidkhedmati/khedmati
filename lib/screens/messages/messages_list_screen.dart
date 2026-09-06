import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import 'chat_screen.dart';

class MessagesListScreen extends StatelessWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
      body: uid == null
          ? const SizedBox()
          : StreamBuilder<List<ChatModel>>(
              stream: firestoreService.streamMyChats(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final chats = snapshot.data ?? [];
                if (chats.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.chat_bubble_outline,
                              size: 56, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text('ماكاينش رسائل دابا',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 6),
                          Text('ابدا محادثة من تفاصيل أي طلب',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE7F1FD),
                        child: Icon(Icons.person, color: AppColors.primaryBlue),
                      ),
                      title: Text(chat.requestTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        chat.lastMessage.isEmpty
                            ? 'ابدا المحادثة دابا...'
                            : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        timeago.format(chat.lastMessageAt, locale: 'ar'),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                      onTap: () {
                        final otherUid = chat.participantIds
                            .firstWhere((id) => id != uid, orElse: () => '');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              title: chat.requestTitle,
                              otherUid: otherUid,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
