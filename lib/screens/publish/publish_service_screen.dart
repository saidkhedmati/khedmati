import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/service_request_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class PublishServiceScreen extends StatefulWidget {
  const PublishServiceScreen({super.key});

  @override
  State<PublishServiceScreen> createState() => _PublishServiceScreenState();
}

class _PublishServiceScreenState extends State<PublishServiceScreen> {
  final _firestoreService = FirestoreService();
  final _descriptionController = TextEditingController();
  final _extraDetailsController = TextEditingController();

  String? _city;
  String? _region;
  String? _jobType;
  bool _isPublishing = false;

  final List<String> _cities = [
    'الدار البيضاء', 'الرباط', 'مراكش', 'فاس', 'طنجة',
    'أكادير', 'مكناس', 'وجدة', 'القنيطرة', 'تطوان',
  ];

  final Map<String, List<String>> _regionsByCity = {
    'الدار البيضاء': ['عين الشق', 'سيدي البرنوصي', 'الحي المحمدي', 'المعاريف'],
    'الرباط': ['أكدال', 'حسان', 'يعقوب المنصور', 'السويسي'],
  };

  final List<String> _jobTypes = [
    'نظافة', 'كهرباء', 'سباكة', 'تصميم', 'بيع', 'مطاعم', 'نقل', 'صيانة', 'برمجة', 'أخرى',
  ];

  List<String> get _availableRegions => _regionsByCity[_city] ?? [];

  @override
  void dispose() {
    _descriptionController.dispose();
    _extraDetailsController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_city == null || _jobType == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عافاك عمر المدينة، نوع العمل والوصف')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final request = ServiceRequestModel(
        id: '',
        userId: user.uid,
        userName: user.displayName ?? user.email ?? '',
        userPhotoUrl: user.photoURL,
        title: 'بحث عن $_jobType',
        city: _city!,
        region: _region,
        category: _jobType!,
        description: _descriptionController.text.trim(),
        extraDetails: _extraDetailsController.text.trim().isEmpty
            ? null
            : _extraDetailsController.text.trim(),
      );

      await _firestoreService.createServiceRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نشر الخدمة بنجاح')),
        );
        setState(() {
          _city = null;
          _region = null;
          _jobType = null;
          _descriptionController.clear();
          _extraDetailsController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('وقع مشكل فالنشر، عاود المحاولة')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نشر خدمة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _FieldLabel('المدينة'),
          CustomDropdownField<String>(
            value: _city,
            hint: 'اختر المدينة',
            icon: Icons.location_city_outlined,
            items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) => setState(() {
              _city = value;
              _region = null;
            }),
          ),
          const SizedBox(height: 16),
          _FieldLabel('المنطقة'),
          CustomDropdownField<String>(
            value: _region,
            hint: 'اختر المنطقة',
            icon: Icons.map_outlined,
            items: _availableRegions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (value) => setState(() => _region = value),
          ),
          const SizedBox(height: 16),
          _FieldLabel('نوع العمل'),
          CustomDropdownField<String>(
            value: _jobType,
            hint: 'اختر نوع العمل',
            icon: Icons.work_outline,
            items: _jobTypes.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
            onChanged: (value) => setState(() => _jobType = value),
          ),
          const SizedBox(height: 16),
          _FieldLabel('الوصف'),
          CustomTextField(
            controller: _descriptionController,
            hint: 'اكتب وصفًا مفصلًا عن العمل المطلوب...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _FieldLabel('التفاصيل الإضافية'),
          CustomTextField(
            controller: _extraDetailsController,
            hint: 'أي تفاصيل إضافية تساعد في توضيح طلبك...',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isPublishing ? null : _publish,
            child: _isPublishing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('نشر'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, right: 2),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ),
    );
  }
}
