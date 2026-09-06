# بناء APK حقيقي بلا بيسي - من الهاتف فقط 📱

كاين حل حقيقي 100%، خدمة GitHub Actions كتبني ليك التطبيق فسيرفرات
مجانية، وكتخرج ليك ملف APK جاهز للتحميل - كلشي من الهاتف بلا بيسي.

---

## الطريقة الأسهل: تطبيق Termux (نصيحة أنصح بيها)

Termux هو تطبيق Android كيعطيك "طرفية" (Terminal) حقيقية فهاتفك،
بيه تقدر تدير أوامر git بحال بيسي حقيقي.

### 1) ثبت Termux
حمل من F-Droid (أحسن من Play Store لأن نسخة Play Store قديمة):
https://f-droid.org/en/packages/com.termux/

### 2) جهز الأدوات جوا Termux
افتح Termux واكتب:
```bash
pkg update -y
pkg install git -y
```

### 3) خلق حساب GitHub (مجاني)
من متصفح هاتفك: https://github.com/signup
سجل بجيميل ديالك، دير اسم مستخدم.

### 4) خلق repository جديد (خاص، مو عام)
1. سير لـ https://github.com/new
2. اسم: `khedmati`
3. اختر **Private** (باش حتى حد ما يشوف الكود)
4. اضغط "Create repository"

### 5) دير Personal Access Token (بدل الكود السري)
GitHub ماعادش كيقبل الكود العادي، خاصك "token":
1. https://github.com/settings/tokens/new
2. اختار صلاحية "repo" (كاملة)
3. Generate token → **نسخ الرمز وحفظو** (مغاديش يبان ليك مرة أخرى)

### 6) دخل الملفات ديال المشروع لهاتفك
- حمل الزيب `khedmati_app.zip` اللي عطيتك من الشات
- فك الضغط عليه بتطبيق "Files" ديال الهاتف (ولا أي تطبيق فك ضغط)
- خاصك تحط `google-services.json` ديالك جوا `android/app/` **قبل** ما ترفع

### 7) ارفع المشروع بـ Termux
جوا Termux:
```bash
# روح لبلاصة الملفات (بدل المسار حسب فين فكيتي الزيب)
cd storage/downloads/khedmati_app

# لأول مرة، خاصك تعطي لTermux صلاحية الوصول للملفات:
termux-setup-storage

git init
git add .
git commit -m "أول نسخة ديال Khedmati"
git branch -M main
git remote add origin https://github.com/USERNAME/khedmati.git
git push -u origin main
```
ملي يطلب `Username` و `Password`: حط اسم المستخدم ديالك،
وفالـ Password **حط الـ Token** اللي نسخيتي (ماشي الكود ديال الحساب).

### 8) تفرج على البناء
1. سير لصفحة الـ repository ديالك فـ GitHub
2. اضغط تبويب **Actions**
3. غادي تلقى "Build Khedmati APK" خدام (نقطة صفراء = كيخدم، خضراء = خلص)
4. ملي يخلص (يولي أخضر ✅)، اضغط عليه، نزل لتحت لـ **Artifacts**
5. حمل `khedmati-apk` - هذا هو ملف APK الحقيقي!

### 9) ثبت التطبيق فهاتفك
- حمل الملف، افتحو
- إيلا قال ليك "ماسموحش بالتثبيت من مصادر مجهولة" → روح لـ Settings
  وسمح بالتثبيت من "Files" ولا المتصفح اللي حملتي بيه
- ثبت وجرب!

---

## ⚠️ ملاحظة مهمة جدا

كل مرة كتبدل شي حاجة فالكود (حتى بسطر واحد) وترفعها بـ
`git add . && git commit -m "تحديث" && git push`،
GitHub غادي يعاود يبني ليك APK جديد أوتوماتيكيا - ماخصكش تعاود
كل الخطوات، غير آخر 3 أوامر.

## إيلا وقع ليك مشكل فـ Termux
قوليا بالضبط شنو طلع ليك (رسالة الخطأ) ونعاونك نصلحو خطوة بخطوة.

## البديل: إيلا لقيتي بيسي ولو لساعة وحدة
فأي سيبر كافيه ولا عند صاحب، الخطوات فـ `README.md` مباشرة أسرع
وأسهل بزاف من Termux (Android Studio + Flutter كيديرو كلشي أوتوماتيك).
