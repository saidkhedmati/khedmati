# Khedmati - خدماتي 🇲🇦

تطبيق موبايل حقيقي (Flutter) لربط الناس اللي كيبغيو خدمة مع مقدمي الخدمات.
مبني بـ Firebase كقاعدة بيانات حقيقية (Auth + Firestore + Storage).

**التطبيق دابا خاوي بالكامل، بلا أي بيانات وهمية** - غادي يبدا يتعمر بالطلبات
والمستخدمين الحقيقيين ملي تبدا تستعملو نتا.

---

## 📁 شنو كاين فهاد المجلد

```
khedmati_app/
├── lib/
│   ├── main.dart                     # نقطة انطلاق التطبيق
│   ├── theme/app_theme.dart          # الألوان والستايل
│   ├── models/                       # نماذج البيانات (User + ServiceRequest)
│   ├── services/                     # التعامل مع Firebase (Auth + Firestore)
│   ├── widgets/                      # عناصر واجهة قابلة لإعادة الاستعمال
│   └── screens/
│       ├── splash_screen.dart
│       ├── auth/login_screen.dart          # شاشة تسجيل الدخول
│       ├── home/home_screen.dart           # الشاشة الرئيسية + شريط التنقل
│       ├── home/account_menu_screen.dart   # قائمة الحساب
│       ├── profile/edit_profile_screen.dart # شاشة "حسابي"
│       ├── requests/requests_screen.dart    # شاشة "الطلبات"
│       └── publish/publish_service_screen.dart # شاشة "نشر خدمة"
├── assets/images/logo.png            # اللوغو ديال التطبيق
├── firestore.rules                   # قواعد الأمان ديال قاعدة البيانات
├── storage.rules                     # قواعد الأمان ديال تخزين الصور
├── database.rules.json               # قواعد الأمان ديال "متصل الآن" (النقطة الصفراء)
├── .github/workflows/build.yml       # بناء APK أوتوماتيك بلا بيسي (GitHub Actions)
├── NO_PC_BUILD_GUIDE.md              # 📱 كيفاش تبني APK حقيقي بلا بيسي
├── GOOGLE_SIGNIN_SETUP.md            # كيفاش تفعل Google Sign-In الحقيقي
└── pubspec.yaml                      # لائحة المكتبات المستعملة
```

---

## 🚀 خطوات التشغيل (خاصك تديرهم بالترتيب)

### 1) تثبيت Flutter
حمل Flutter SDK من هنا: https://docs.flutter.dev/get-started/install
وتأكد من التثبيت بـ:
```bash
flutter doctor
```

### 2) خلق مشروع Flutter وحط فيه هاد الملفات

دابا مجلد `android/` **معمر بالكامل** فهاد الزيب (applicationId = `com.khedmati.app`،
Google Sign-In، الصلاحيات، اللوغو الحقيقي...). خاصك غير:

```bash
flutter create --org com.khedmati --project-name khedmati khedmati_temp
```

من بعد:
1. احذف مجلد `android/` و `ios/` اللي تولدو فـ `khedmati_temp`
2. انسخ ليه بلاصتهم `lib/`, `pubspec.yaml`, `assets/`, `android/` اللي صاوبت ليك
3. (اختياري) إيلا بغيتي iOS زيد `flutter create --platforms=ios .` من جوج المجلد

### 3) خلق مشروع Firebase حقيقي (قاعدة البيانات)

> 🔑 إيلا عندك ديجا ملف `google-services.json` محمل من Firebase Console،
> اقرا `GOOGLE_SIGNIN_SETUP.md` مباشرة - فيه كل الخطوات الدقيقة باش يخدم
> "متابعة مع Google" بشكل حقيقي (بما فيها الخطوة المهمة ديال SHA-1).
>
> ⚠️ خاص يكون عندك تطبيق Android جديد فـ Firebase بـ package name =
> **com.khedmati.app** بالضبط (ماشي `com.example.khedmati`)، وحط
> `google-services.json` فـ `android/app/google-services.json`.

1. سير لـ https://console.firebase.google.com وخلق مشروع جديد اسمو "Khedmati"
2. فـ Authentication > Sign-in method: فعّل **Email/Password** و **Google**
3. فـ Firestore Database: خلق قاعدة بيانات (وضع Production)
4. فـ Storage: فعّلها (باش تتخزن صور البروفايل)
5. فـ Realtime Database: خلقها (باش يخدم نظام "متصل الآن" - النقطة الصفراء)
5. ✅ **ماخصكش `flutterfire configure`** - راه ديجا مربوط عبر `google-services.json`
   اللي حطيتي فـ `android/app/`. `main.dart` كيستعمل `Firebase.initializeApp()`
   بلا "options" وكيقرا الإعدادات مباشرة من هاداك الملف.

### 4) نسخ قواعد الأمان
- انسخ محتوى `firestore.rules` لـ Firebase Console > Firestore Database > Rules
- انسخ محتوى `storage.rules` لـ Firebase Console > Storage > Rules
- انسخ محتوى `database.rules.json` لـ Firebase Console > Realtime Database > Rules

### 5) تثبيت المكتبات وتشغيل التطبيق
```bash
flutter pub get
flutter run
```

وصل تيليفون ولا شغل محاكي (Emulator) باش يبان ليك التطبيق.

### 6) بناء نسخة نهائية (APK) للأندرويد
```bash
flutter build apk --release
```
غادي تلقى الملف فـ `build/app/outputs/flutter-apk/app-release.apk`
قادر تبعتو لأي تيليفون أندرويد وتثبتو مباشرة.

لـ iOS خاصك Mac مع Xcode:
```bash
flutter build ios --release
```

---

## ✅ شنو خدام دابا (وظائف حقيقية، ماشي تصميم غير)

- تسجيل حساب جديد / تسجيل الدخول بـ Gmail وكود (Firebase Auth حقيقي)
- تسجيل الدخول بـ Google الحقيقي (شوف `GOOGLE_SIGNIN_SETUP.md`)
- تعديل البروفايل الكامل (الاسم، الهاتف، تاريخ الميلاد، الجنس، المدينة،
  العنوان، النبذة، المهارات، اللغة) + رفع صورة البروفايل
- نشر طلب خدمة جديد (كيتسجل مباشرة فـ Firestore)
- عرض لائحة الطلبات (كتبدا خاوية، كتتعمر بالطلبات الحقيقية اللي كيديرو الناس)
- **محادثة حقيقية مباشرة** بين طالب الخدمة ومقدمها (Firestore real-time -
  الرسائل كتوصل مباشرة عبر الواي فاي/الإنترنت، بلا حاجة تعاود تفتح الصفحة)
- **نقطة "متصل الآن" حقيقية** (صفراء) حدا صورة أي مستخدم - كتبان ملي يكون
  فاتح التطبيق فعلا، وكتزول أوتوماتيك ملي يسدو أو يطيح النت ديالو
  (نظام Firebase Presence الرسمي، شوف `lib/services/presence_service.dart`)
- تسجيل الخروج

## 🔜 شنو خاصك تزيد (إذا بغيتي)
- شاشة الإشعارات (زر الجرس دابا placeholder)
- شاشة "خدماتي المنشورة" (دابا كاين المسار، خاصها تعمر بلائحة حقيقية)

---

## 📱 ما عندكش بيسي؟

اقرا `NO_PC_BUILD_GUIDE.md` - فيه طريقة تبني بيها APK حقيقي بلا بيسي،
غير بهاتفك، عبر GitHub Actions (مجاني بالكامل).

---

**ملاحظة مهمة**: التطبيق فيه أسماء مدن ومناطق ومهارات مكتوبة فالكود
(كأمثلة فالقوائم المنسدلة) - هادو ماشي "بيانات وهمية ديال ناس"، غير
خيارات فالفورم باش تختار منها، بحال أي تطبيق حقيقي. البيانات الوهمية
(المستخدمين والطلبات) ما كايناش، التطبيق خاوي 100% وغادي يتعمر بيك نتا.
