import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// كل العمليات ديال تسجيل الدخول والتسجيل الجديد خدامة عليها هاد الكلاس.
/// كتخدم مع Firebase Authentication الحقيقي (ماشي وهمي).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// تسجيل الدخول بـ Gmail وكود (password)
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// إنشاء حساب جديد بـ Gmail وكود، وكيدير ليه مباشرة وثيقة فارغة فـ users
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final uid = credential.user!.uid;
    final emptyUser = UserModel.empty(uid: uid, email: email.trim());
    await _firestore.collection('users').doc(uid).set(emptyUser.toMap());

    return credential;
  }

  /// تسجيل الدخول بـ Google - إذا كانت أول مرة كيخلق ليه حساب فارغ فـ Firestore
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // المستخدم لغى العملية

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final uid = userCredential.user!.uid;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final newUser = UserModel(
        uid: uid,
        fullName: userCredential.user!.displayName ?? '',
        email: userCredential.user!.email ?? '',
        photoUrl: userCredential.user!.photoURL,
      );
      await docRef.set(newUser.toMap());
    }

    return userCredential;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
