import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/user.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Track the current auth user ID to detect account changes
final _currentAuthIdProvider = StateProvider<String?>((ref) => null);

// Cache the user data with their ID as key
final cachedUserProvider = StateProvider<AppUser?>((ref) => null);

// Stream auth state changes and manage cache
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    // Clear cache if user signs out or switches accounts
    final currentAuthId = ref.read(_currentAuthIdProvider);
    if (user?.uid != currentAuthId) {
      ref.read(cachedUserProvider.notifier).state = null;
      ref.read(_currentAuthIdProvider.notifier).state = user?.uid;
    }
    return user;
  });
});

// Stream user data and update cache
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  if (authState == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection(customerSpecificCollectionUsers)
      .doc(authState.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final appUser = AppUser.fromDocument(doc, doc.id);
    // Update cache
    ref.read(cachedUserProvider.notifier).state = appUser;
    return appUser;
  });
});

// Authentication status tracking
final authStatusProvider = Provider<AuthStatus>((ref) {
  final firebaseUser = ref.watch(authStateProvider).value;
  final appUser = ref.watch(currentUserProvider).value;

  if (firebaseUser == null) {
    return AuthStatus.unauthenticated;
  }

  if (!firebaseUser.emailVerified) {
    return AuthStatus.unverified;
  }

  if (appUser == null) {
    return AuthStatus.initial;
  }

  return AuthStatus.authenticated;
});

// Keep the refresh provider for manual updates
final refreshUserProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.read(cachedUserProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
  };
});
