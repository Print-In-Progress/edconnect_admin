import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/shared_prefs.dart';

Future<void> initializeColorScheme(WidgetRef ref) async {
  final prefs = AppPreferences();
  final lastFetchTimestamp = await prefs.getInt('lastColorFetch') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  // First load from cache
  await loadColorsFromCache(ref);

  // Check if refresh is needed
  bool refreshNeeded = false;

  // Refresh if cache is older than 24 hours
  if (now - lastFetchTimestamp > const Duration(days: 1).inMilliseconds) {
    refreshNeeded = true;
  }

  if (refreshNeeded) {
    // Refresh in background if needed
    unawaited(refreshColorsFromFirestore(ref).then((_) async {
      await prefs.setInt('lastColorFetch', now);
      debugPrint('Background color refresh completed');
    }).catchError((error) {
      debugPrint('Error in background refresh: $error');
    }));
  }
}

Future<void> refreshColorsFromFirestore(WidgetRef ref) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(customerSpecificRootCollectionName)
        .doc('newsapp')
        .get();

    if (!doc.exists || doc.data() == null) return;

    final data = doc.data()!;
    final prefs = AppPreferences();

    // Parse colors
    if (data['primary_color']?.isNotEmpty ?? false) {
      final primaryColor = Color(int.parse(data['primary_color'], radix: 16));
      final secondaryColor = data['secondary_color']?.isNotEmpty ?? false
          ? Color(int.parse(data['secondary_color'], radix: 16))
          : const Color(0xFF01629C);

      await prefs.setColors(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    // Store logo link
    if (data['logo_link']?.isNotEmpty ?? false) {
      await prefs.setLogoLink(data['logo_link']);
    }

    // Update the provider with new values
    await loadColorsFromCache(ref);
  } catch (e) {
    debugPrint('Error refreshing colors from Firestore: $e');
  }
}

Future<void> loadColorsFromCache(WidgetRef ref) async {
  try {
    final prefs = AppPreferences();

    // Get colors from SharedPreferences
    final colors = await prefs.getColors();
    final logoLink = await prefs.getLogoLink();

    // Update the provider with cached values
    ref.read(colorAndLogoProvider.notifier).updateColors(
          primaryColor: colors.primaryColor,
          secondaryColor: colors.secondaryColor,
          logoLink: logoLink,
          customerName: customerName,
        );
  } catch (e) {
    debugPrint('Error loading colors from cache: $e');
    // Use default values
    ref.read(colorAndLogoProvider.notifier).updateColors(
          primaryColor: const Color(0xFF192B4C),
          secondaryColor: const Color(0xFF01629C),
          logoLink: 'assets/edconnect_mobile.png',
          customerName: '',
        );
  }
}
