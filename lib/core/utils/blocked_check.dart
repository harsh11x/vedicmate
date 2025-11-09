import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Utility to check if a Pandit account is blocked
// This would typically check against a backend API or local storage

class BlockedCheck {
  // Mock function - in production, this would check against backend
  static bool isPanditBlocked(String panditId) {
    // Mock blocked IDs - in production, fetch from API
    final blockedIds = ['3']; // Example: Pandit ID '3' is blocked
    return blockedIds.contains(panditId);
  }

  // Check and redirect if blocked
  static void checkAndRedirect(BuildContext context, String panditId) {
    if (isPanditBlocked(panditId)) {
      context.go('/pandit/blocked');
    }
  }
}

