import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  String? _city;
  List<String> _skills = [];
  String? _language;

  File? _pickedImage;
  String? _existingPhotoUrl;
  bool _isLoading = false;
  bool _isSaving = false;

  final List<String> _genders = ['ذكر', 'أنثى'];
  final List<String> _cities = [
    'الدار البيضاء', 'الرباط', 'مراكش', 'فاس', 'طنجة',
    'أكادير', 'مكناس', 'وجدة', 'القنيطرة', 'تطوان',
  ];
  final List<String> _availableSkills = [
    'نظافة', 'كهرباء', 'سباكة', 'تصميم', 'برمجة',
    'طبخ', 'نجارة', 'دهن', 'بيع', 'نقل',
  ];
  final List<String> _languages = ['العربية', 'الفرنسية', 'الإنجليزية', 'الأمازيغية'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isLoading = true);
    final profile = await _firestoreService.getUser(uid);
    if (profile != null) {
      _fullNameController.text = profile.fullName;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _addressController.text = profile.address ?? '';
      _bioController.text = profile.bio ?? '';
      _birthDate = profile.birthDate;
      _gender = profile.gender;
      _city = profile.city;
      _skills = List.from(profile.skills);
      _language = profile.language;
      _existingPhotoUrl = profile.photoUrl;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickSkills() async {
    final selected = List<String>.from(_skills);
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('اختر مهاراتك',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSkills.map((skill) {
                      final isSelected = selected.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue.withOpacity(0.15),
                        onSelected: (value) {
                          setModalState(() {
                            if (value) {
                              selected.add(skill);
                            } else {
                              selected.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: const Text('تم'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) setState(() => _skills = result);
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      String? photoUrl = _existingPhotoUrl;
      if (_pickedImage != null) {
        photoUrl = await _firestoreService.uploadProfilePhoto(uid, _pickedImage!);
      }

      final updatedUser = UserModel(
        uid: uid,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: photoUrl,
        birthDate: _birthDate,
        gender: _gender,
        city: _city,
        address: _addressController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
        language: _language,
      );

      await _firestoreService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('وقع مشكل فحفظ البيانات، عاود المحاولة')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_existingPhotoUrl != null
                                ? NetworkImage(_existingPhotoUrl!)
                                : null) as ImageProvider?,
                        child: (_pickedImage == null && _existingPhotoUrl == null)
                            ? const Icon(Icons.person,
                                size: 55, color: AppColors.primaryBlue)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(Icons.camera_alt_outlined, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'المعلومات الشخصية', icon: Icons.person_outline),
                const SizedBox(height: 12),
                _FieldLabel('الاسم الكامل'),
                CustomTextField(
                  controller: _fullNameController,
                  hint: 'اكتب اسمك الكامل',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                _FieldLabel('البريد الإلكتروني'),
                CustomTextField(
                  controller: _emailController,
                  hint: 'example@gmail.com',
                  icon: Icons.email_outlined,
                  readOnly: true,
                ),
                const SizedBox(height: 14),
                _FieldLabel('رقم الهاتف'),
                CustomTextField(
                  controller: _phoneController,
                  hint: '+212 6 12 34 56 78',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _FieldLabel('تاريخ الميلاد'),
                CustomTextField(
                  controller: TextEditingController(
                    text: _birthDate != null
                        ? DateFormat('yyyy/MM/dd').format(_birthDate!)
                        : '',
                  ),
                  hint: 'اختر تاريخ ميلادك',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _pickBirthDate,
                ),
                const SizedBox(height: 14),
                _FieldLabel('الجنس'),
                CustomDropdownField<String>(
                  value: _gender,
                  hint: 'اختر جنسك',
                  icon: Icons.wc_outlined,
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 14),
                _FieldLabel('المدينة'),
                CustomDropdownField<String>(
                  value: _city,
                  hint: 'اختر مدينتك',
                  icon: Icons.location_on_outlined,
                  items: _cities
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => setState(() => _city = value),
                ),
                const SizedBox(height: 14),
                _FieldLabel('العنوان'),
                CustomTextField(
                  controller: _addressController,
                  hint: 'اكتب عنوانك بالتفصيل',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'معلومات إضافية', icon: Icons.info_outline),
                const SizedBox(height: 12),
                _FieldLabel('نبذة عنك'),
                CustomTextField(
                  controller: _bioController,
                  hint: 'اكتب نبذة مختصرة عن نفسك وما تقدمه...',
                  icon: Icons.person_outline,
                  maxLines: 4,
                  maxLength: 200,
                ),
                const SizedBox(height: 14),
                _FieldLabel('المهارات'),
                InkWell(
                  onTap: _pickSkills,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.star_border, color: AppColors.primaryBlue),
                    ),
                    child: Text(
                      _skills.isEmpty ? 'اختر مهاراتك' : _skills.join('، '),
                      style: TextStyle(
                        color: _skills.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel('اللغة'),
                CustomDropdownField<String>(
                  value: _language,
                  hint: 'اختر لغتك',
                  icon: Icons.language,
                  items: _languages
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) => setState(() => _language = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('حفظ التغييرات'),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Icon(icon, size: 18, color: AppColors.primaryBlue),
      ],
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
