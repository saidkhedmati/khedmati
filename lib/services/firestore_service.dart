import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../models/service_request_model.dart';
import '../models/chat_model.dart';

/// كل التعامل مع قاعدة البيانات Firestore (وتخزين الصور فـ Storage) مجمع هنا.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------------- المستخدمين ----------------

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Stream<UserModel?> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(uid, doc.data()!);
    });
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  /// كيرفع صورة البروفايل لـ Firebase Storage وكيرجع الرابط ديالها
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage.ref().child('profile_photos/$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ---------------- طلبات الخدمة ----------------

  /// نشر خدمة جديدة (من شاشة "نشر خدمة")
  Future<void> createServiceRequest(ServiceRequestModel request) async {
    await _db.collection('requests').add(request.toMap());
  }

  /// قائمة كل الطلبات، الأحدث فالأول - بلا أي بيانات وهمية، كتبان خاوية
  /// حتى يبدا الناس يستعملو التطبيق وينشرو خدمات حقيقية.
  Stream<List<ServiceRequestModel>> streamAllRequests() {
    return _db
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// الطلبات ديال مدينة معينة (تبويب "قريب منك")
  Stream<List<ServiceRequestModel>> streamRequestsByCity(String city) {
    return _db
        .collection('requests')
        .where('city', isEqualTo: city)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// الخدمات المنشورة من طرف مستخدم معين
  Stream<List<ServiceRequestModel>> streamMyRequests(String uid) {
    return _db
        .collection('requests')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ServiceRequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> deleteServiceRequest(String requestId) async {
    await _db.collection('requests').doc(requestId).delete();
  }

  // ---------------- المحادثات (Chat حقيقي مباشر) ----------------

  /// كيبحث على محادثة موجودة لهاد الطلب بين هاد الجوج ديال الناس،
  /// وإيلا ماكايناش كيخلق وحدة جديدة. هكا ماتتكررش المحادثة كل مرة.
  Future<String> getOrCreateChat({
    required String requestId,
    required String requestTitle,
    required String myUid,
    required String otherUid,
  }) async {
    final existing = await _db
        .collection('chats')
        .where('requestId', isEqualTo: requestId)
        .where('participantIds', arrayContains: myUid)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc['participantIds']);
      if (participants.contains(otherUid)) return doc.id;
    }

    final chat = ChatModel(
      id: '',
      requestId: requestId,
      requestTitle: requestTitle,
      participantIds: [myUid, otherUid],
    );
    final ref = await _db.collection('chats').add(chat.toMap());
    return ref.id;
  }

  /// كل المحادثات ديال مستخدم معين، الأحدث فالأول - كتحدث بشكل حي (real-time)
  Stream<List<ChatModel>> streamMyChats(String uid) {
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatModel.fromMap(d.id, d.data())).toList());
  }

  /// رسائل محادثة معينة - كتحدث بشكل حي، هذا هو "الأونلاين" الحقيقي:
  /// ملي الشخص الآخر يبعت رسالة وهو متصل بالواي فاي/الأنترنت، كتبان
  /// ليك مباشرة بلا ما تعاود تفتح الصفحة
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MessageModel.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final message = MessageModel(id: '', senderId: senderId, text: text);
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': Timestamp.now(),
    });
  }
}
