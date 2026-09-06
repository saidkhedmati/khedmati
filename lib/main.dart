import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/presence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ إذا كنت حطيتي android/app/google-services.json (وiOS: GoogleService-Info.plist)،
  // Firebase.initializeApp() بلا "options" كافي، Flutter كيقرا الملف تلقائيا.
  // (خاصك تراجع GOOGLE_SIGNIN_SETUP.md لمعرفة الخطوات الكاملة إلى ماخدمش Google Sign-In)
  await Firebase.initializeApp();

  runApp(const KhedmatiApp());
}

class KhedmatiApp extends StatelessWidget {
  const KhedmatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khedmati',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // كل التطبيق باللغة العربية ومن اليمين لليسار
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}

/// كيقرر شكون كيبان أول: شاشة تسجيل الدخول ولا الصفحة الرئيسية،
/// حسب واش المستخدم مسجل الدخول فعلا فـ Firebase.
/// وهنا كذلك كنشغّلو نظام "متصل الآن" الحقيقي (النقطة الصفراء).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  final _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ملي المستخدم يسد التطبيق (يخليه فالخلفية) كنبدلو الحالة لـ "ماشي متصل"
    // وملي يرجع ليه كنعاودو نفعلو "متصل" - النقطة الصفراء كتبان/تزول أوتوماتيك
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _presenceService.setOffline();
    } else if (state == AppLifecycleState.resumed) {
      _presenceService.startTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          _presenceService.startTracking();
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
