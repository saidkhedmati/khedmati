# إعداد Google Sign-In الحقيقي (Android + Play Store)

هاد الملف كيشرح بالضبط الخطوات اللي خاصك تديرها باش يخدم "متابعة مع Google"
بشكل حقيقي 100% فتطبيقك، بما فيه ملي تنشرو فـ Play Store.

⚠️ **مهم بزاف**: `google-services.json` وحدو ماكافيش. Google Sign-In محتاج
كذلك بصمة التوقيع ديال التطبيق (SHA-1) - هاد الخطوة هي اللي غالبا كيناسوها الناس
وكيطلع ليهم خطأ (ApiException: 10) ملي كيجربو Google Sign-In.

---

## 1) حط ملف google-services.json فبلاصتو

```
khedmati/
└── android/
    └── app/
        └── google-services.json   👈 هنا بالضبط
```

تأكد بلي اسم الحزمة (`package_name`) جوا الملف كيطابق بالضبط
`applicationId` اللي فـ `android/app/build.gradle` (شوف الخطوة 5).

---

## 2) بدل android/build.gradle (على مستوى المشروع)

زيد هاد السطر جوا `dependencies { ... }`:

```gradle
buildscript {
    dependencies {
        // ... الأسطر الموجودين
        classpath 'com.google.gms:google-services:4.4.2'
    }
}
```

---

## 3) بدل android/app/build.gradle (على مستوى التطبيق)

زيد هاد السطر فالأول ديال الملف (مع باقي الـ plugins):

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"   // 👈 زيد هاد السطر
}
```

وتأكد `minSdkVersion` يكون 21 على الأقل (Google Sign-In محتاج هاد الشي):

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

---

## 4) الخطوة الأهم: SHA-1 (بلاها Google Sign-In ماغاديش يخدم)

Google محتاج يعرف "بصمة" التوقيع ديال التطبيق ديالك باش يثق فيه.
خاصك تزيد **جوج** بصمات فـ Firebase: وحدة للتجربة (debug) ووحدة للنشر (release).

### أ) بصمة التجربة (debug) - باش تجرب دابا فهاتفك
```bash
cd android
./gradlew signingReport
```
غادي تلقى فالنتيجة سطر `SHA1: XX:XX:XX...` تحت `Variant: debug`. نسخو.

### ب) بصمة النشر (release) - خاصها قبل ما تنشر فـ Play Store
إيلا كنتي غادي تستعمل **Play App Signing** (هو الافتراضي دابا فـ Play Console):
1. سير لـ Play Console > تطبيقك > Setup > App integrity
2. نسخ "SHA-1 certificate fingerprint" اللي كاين تما (ديال Google نفسها)

### ج) زيد البصمات فـ Firebase
1. Firebase Console > Project Settings > تطبيق Android ديالك
2. "Add fingerprint" وحط بصمة الـ debug، وعاود دير نفس الشي لبصمة الـ release
3. **حمل google-services.json من جديد** بعد ما تزيد البصمات، وبدلو بالقديم

---

## 5) تفعيل Google كوسيلة تسجيل دخول

1. Firebase Console > Authentication > Sign-in method
2. فعّل **Google**
3. اختر بريد إلكتروني للدعم (support email) - إجباري

---

## 6) تأكد من اسم الحزمة

```gradle
// android/app/build.gradle
defaultConfig {
    applicationId "com.example.khedmati"   // 👈 خاصو يطابق بالضبط google-services.json
}
```

---

## 7) جرب

```bash
flutter clean
flutter pub get
flutter run
```

اضغط "متابعة مع Google" - خاص يبان ليك منتقي حسابات Google الحقيقي ديال الهاتف.

---

## ✅ لائحة تأكد قبل النشر فـ Play Store

- [ ] `google-services.json` محطوط فـ `android/app/`
- [ ] بصمة SHA-1 ديال الـ **debug** مزيدة فـ Firebase
- [ ] بصمة SHA-1 ديال الـ **release** (Play App Signing) مزيدة فـ Firebase
- [ ] حملتي `google-services.json` **جديد** من بعد ما زدتي البصمات
- [ ] Google مفعّل فـ Authentication > Sign-in method
- [ ] `applicationId` كيطابق اسم الحزمة فـ google-services.json
- [ ] جربتي Google Sign-In فتطبيق مبني بـ `flutter build apk --release` (ماشي غير debug)

إيلا طلع ليك خطأ `ApiException: 10` معناها ناقصة شي بصمة SHA-1 فـ Firebase.
