import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/online_dot.dart';
import '../profile/edit_profile_screen.dart';
import '../messages/messages_list_screen.dart';
import '../services/my_services_screen.dart';

class AccountMenuScreen extends StatelessWidget {
  const AccountMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khedmati'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: وصل هنا شاشة الإشعارات ملي تديرها
            },
            icon: const Icon(Icons.notifications_none),
          ),
        ],
        leading: IconButton(
          onPressed: () {
            // TODO: وصل هنا شاشة الإعدادات ملي تديرها
          },
          icon: const Icon(Icons.settings_outlined),
        ),
      ),
      body: StreamBuilder(
        stream: user != null ? firestoreService.streamUser(user.uid) : null,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final displayName = (profile?.fullName.isNotEmpty ?? false)
              ? profile!.fullName
              : 'اكتب اسمك الكامل';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Center(
                child: Column(
                  children: [
                    AvatarWithPresence(
                      uid: user?.uid ?? '',
                      dotSize: 16,
                      avatar: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        backgroundImage: profile?.photoUrl != null
                            ? NetworkImage(profile!.photoUrl!)
                            : null,
                        child: profile?.photoUrl == null
                            ? const Icon(Icons.person,
                                size: 50, color: AppColors.primaryBlue)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(displayName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _MenuItem(
                icon: Icons.person_outline,
                label: 'حسابي',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.work_outline,
                label: 'خدماتي المنشورة',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyServicesScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline,
                label: 'الرسائل',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessagesListScreen()),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService().signOut();
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: const Text('تسجيل الخروج',
                    style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(label),
        trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
