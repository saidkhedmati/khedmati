import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// نظام "متصل الآن" حقيقي 100%.
///
/// كيفاش كيخدم بالضبط:
/// Firebase Realtime Database فيها بلاصة خاصة اسمها ".info/connected" -
/// هاذي كتبدل لـ true/false تلقائيا من طرف سيرفرات Firebase نفسها حسب
/// واش الهاتف مازال مرتبط بالإنترنت (WiFi ولا بيانات) و لا لا.
///
/// و onDisconnect() هو أمر كنعطيه للسيرفر: "إيلا تقطع هاد الهاتف
/// (طفا التطبيق، خرج من الإنترنت، تهنقات البطارية...)، بدل الحالة ديالو
/// لـ 'offline' من بعدي حتى إيلا ما قدرش يبعت الأمر بنفسو."
/// هاد الشي هو اللي كيخلي النقطة الصفراء تزول أوتوماتيكيا وبشكل موثوق،
/// حتى ملي التطبيق يتسد بقوة أو يطيح النت - بلا حاجة لأي كود إضافي.
class PresenceService {
  final _db = FirebaseDatabase.instance;

  void startTracking() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final myStatusRef = _db.ref('status/$uid');
    final connectedRef = _db.ref('.info/connected');

    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value == true;
      if (!isConnected) return;

      // ملي يتقطع الاتصال (بأي طريقة)، السيرفر غادي يبدل الحالة وحدو
      await myStatusRef.onDisconnect().set({
        'online': false,
        'lastSeen': ServerValue.timestamp,
      });

      // ودابا كنأكدو بلي حنا متصلين
      await myStatusRef.set({
        'online': true,
        'lastSeen': ServerValue.timestamp,
      });
    });
  }

  Future<void> setOffline() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.ref('status/$uid').set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
  }

  /// كنتتبعو فيها حالة أي مستخدم آخر (باش نبينو النقطة الصفراء حداه)
  Stream<bool> streamOnlineStatus(String uid) {
    return _db.ref('status/$uid/online').onValue.map((event) {
      return event.snapshot.value == true;
    });
  }
}
