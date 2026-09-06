import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/service_request_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

/// شاشة "خدماتي المنشورة" - كل طلب فيه زر سلة مهملات باش تحيدو
/// ملي تكون لقيتي الخدام اللي بغيتي وماعادش محتاج الطلب يبقى منشور.
class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String requestId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الطلب'),
        content: const Text('واش متأكد بغيتي تحيد هاد الطلب؟ ماغاديش يبان من بعد.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirestoreService().deleteServiceRequest(requestId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الطلب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('خدماتي المنشورة'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_forward_ios, size: 18),
        ),
      ),
      body: uid == null
          ? const SizedBox()
          : StreamBuilder<List<ServiceRequestModel>>(
              stream: firestoreService.streamMyRequests(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.work_outline,
                              size: 56, color: AppColors.textSecondary),
                          SizedBox(height: 16),
                          Text('ماعندكش أي خدمة منشورة دابا',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 6),
                          Text('نشر خدمة جديدة من زر "نشر خدمة"',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFE7F1FD),
                            child: Icon(Icons.person, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14.5)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(r.category,
                                      style: const TextStyle(
                                          color: AppColors.primaryBlue, fontSize: 11)),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${r.city} · ${timeago.format(r.createdAt, locale: 'ar')}',
                                  style: const TextStyle(
                                      fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // 🗑️ زر حذف الطلب - ملي يلقى الشخص خدامو ماعادش محتاجو
                          IconButton(
                            onPressed: () => _confirmDelete(context, r.id),
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            tooltip: 'حذف الطلب',
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
