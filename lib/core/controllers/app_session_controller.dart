import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/models/app_user_profile.dart';
import '../../routes/app_routes.dart';
import '../services/user_profile_service.dart';

class AppSessionController extends GetxController {
  AppSessionController({
    FirebaseAuth? auth,
    UserProfileService? profileService,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _profileService = profileService ?? UserProfileService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final FirebaseAuth _auth;
  final UserProfileService _profileService;
  final GoogleSignIn _googleSignIn;

  final Rxn<User> _firebaseUser = Rxn<User>();
  final Rxn<AppUserProfile> _profile = Rxn<AppUserProfile>();
  final RxBool isReady = false.obs;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUserProfile?>? _profileSubscription;
  final Completer<void> _bootstrapCompleter = Completer<void>();

  User? get firebaseUser => _firebaseUser.value;
  AppUserProfile? get profile => _profile.value;
  bool get isAuthenticated => firebaseUser != null;
  bool get hasPasswordProvider =>
      firebaseUser?.providerData
          .any((provider) => provider.providerId == 'password') ??
      false;

  String? get userName => profile?.hasDisplayName == true
      ? profile!.displayName
      : firebaseUser?.displayName;

  String? get email => profile?.email ?? firebaseUser?.email;

  bool get isNewUser {
    final value = userName?.trim();
    return value == null || value.isEmpty;
  }

  String get displayName {
    final value = userName?.trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }

    final emailValue = email?.trim();
    if (emailValue != null &&
        emailValue.isNotEmpty &&
        emailValue.contains('@')) {
      return emailValue.split('@').first;
    }

    return 'there';
  }

  String get authProviderLabel {
    final providerIds = profile?.providerIds ??
        firebaseUser?.providerData
            .map((provider) => provider.providerId)
            .toList() ??
        const <String>[];

    if (providerIds.contains('apple.com')) {
      return 'Apple';
    }
    if (providerIds.contains('google.com')) {
      return 'Google';
    }
    if (providerIds.contains('password')) {
      return 'Email';
    }
    return 'Account';
  }

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  Future<void> waitUntilReady() => _bootstrapCompleter.future;

  Future<void> _handleAuthChanged(User? user) async {
    _firebaseUser.value = user;
    await _profileSubscription?.cancel();
    _profileSubscription = null;
    _profile.value = null;

    if (user == null) {
      _markReady();
      return;
    }

    final ensuredProfile = await _profileService.ensureProfileForUser(user);
    _profile.value = ensuredProfile;
    _profileSubscription =
        _profileService.watchProfile(user.uid).listen((value) {
      if (value != null) {
        _profile.value = value;
      }
    });
    _markReady();
  }

  void _markReady() {
    isReady.value = true;
    if (!_bootstrapCompleter.isCompleted) {
      _bootstrapCompleter.complete();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _syncUser(credential.user);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'We could not create your account.',
      );
    }

    await _syncUser(_auth.currentUser ?? user);
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in was canceled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    await _syncUser(userCredential.user,
        preferredDisplayName: googleUser.displayName);
  }

  Future<void> signInWithApple() async {
    if (!GetPlatform.isIOS && !GetPlatform.isMacOS) {
      throw Exception('Apple Sign In is only available on Apple devices.');
    }

    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final fullName = [
      appleIdCredential.givenName,
      appleIdCredential.familyName,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

    if (fullName.isNotEmpty) {
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.reload();
    }

    await _syncUser(_auth.currentUser ?? userCredential.user,
        preferredDisplayName: fullName);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<String> updateProfile({
    required String displayName,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You need to be signed in to update your profile.');
    }

    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim();
    if (trimmedName.isEmpty) {
      throw Exception('Please enter your name.');
    }
    if (trimmedEmail.isEmpty) {
      throw Exception('Please enter your email.');
    }

    final messages = <String>[];

    if ((user.displayName ?? '').trim() != trimmedName) {
      await user.updateDisplayName(trimmedName);
      messages.add('Name updated');
    }

    if ((user.email ?? '').trim() != trimmedEmail) {
      await user.verifyBeforeUpdateEmail(trimmedEmail);
      messages.add('Verification email sent to $trimmedEmail');
    }

    await user.reload();
    final refreshedUser = _auth.currentUser ?? user;
    await _profileService.updateProfile(
      user: refreshedUser,
      displayName: trimmedName,
      email: refreshedUser.email,
    );
    await _syncUser(refreshedUser, preferredDisplayName: trimmedName);

    if (messages.isEmpty) {
      return 'No changes to save.';
    }

    return messages.join('. ');
  }

  Future<void> saveName(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(trimmed);
      await user.reload();
      final refreshedUser = _auth.currentUser ?? user;
      await _profileService.updateProfile(
        user: refreshedUser,
        displayName: trimmed,
        email: refreshedUser.email,
      );
      await _syncUser(refreshedUser, preferredDisplayName: trimmed);
      return;
    }

    _profile.value = AppUserProfile(
      uid: '',
      email: null,
      displayName: trimmed,
      photoUrl: null,
      providerIds: const [],
    );
  }

  void completeAuth() {
    if (!isAuthenticated) {
      Get.offAllNamed(AppRoutes.welcome);
      return;
    }

    if (isNewUser) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    Get.offAllNamed(AppRoutes.dashboard);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.welcome);
  }

  Future<void> _syncUser(
    User? user, {
    String? preferredDisplayName,
  }) async {
    if (user == null) {
      return;
    }

    _firebaseUser.value = user;
    final ensuredProfile = await _profileService.ensureProfileForUser(
      user,
      preferredDisplayName: preferredDisplayName,
    );
    _profile.value = ensuredProfile;
  }

  String describeError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address looks invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Those sign in details do not match our records.';
        case 'email-already-in-use':
          return 'That email is already being used.';
        case 'weak-password':
          return 'Weak password. Try a stronger one.';
        case 'operation-not-allowed':
          return 'Email/password sign in is not enabled for this Firebase project yet.';
        case 'requires-recent-login':
          return 'Please sign in again before changing your email.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign in method.';
        case 'internal-error':
          return 'We could not complete that right now. Please try again.';
        default:
          return error.message ?? 'Something went wrong. Please try again.';
      }
    }

    if (error is SignInWithAppleAuthorizationException) {
      if (error.code.name == 'canceled') {
        return 'Apple sign in was canceled.';
      }
      return 'Apple sign in could not be completed. Please try again.';
    }

    if (error is SignInWithAppleNotSupportedException) {
      return 'Apple sign in is not available on this device.';
    }

    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    final normalizedMessage = message.toLowerCase();
    if (normalizedMessage.contains('google sign in was canceled')) {
      return 'Google sign in was canceled.';
    }
    if (normalizedMessage.contains('authorizationerrorcode.canceled') ||
        (normalizedMessage.contains('apple') &&
            normalizedMessage.contains('canceled'))) {
      return 'Apple sign in was canceled.';
    }
    if (normalizedMessage.contains('com.apple.authenticationservices') ||
        normalizedMessage.contains('authorizationerrorcode') ||
        normalizedMessage.contains('platformexception') ||
        normalizedMessage.contains('firebaseauthexception')) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }
}
