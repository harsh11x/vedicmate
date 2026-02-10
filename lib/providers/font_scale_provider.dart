import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _fontScaleKey = 'font_scale';

/// Font scale values: Small=0.85, Medium=1.0, Large=1.2
enum FontScalePreset { small, medium, large }

extension FontScalePresetExt on FontScalePreset {
  double get value {
    switch (this) {
      case FontScalePreset.small: return 0.85;
      case FontScalePreset.medium: return 1.0;
      case FontScalePreset.large: return 1.2;
    }
  }

  String get label {
    switch (this) {
      case FontScalePreset.small: return 'Small';
      case FontScalePreset.medium: return 'Medium';
      case FontScalePreset.large: return 'Large';
    }
  }
}

class FontScaleNotifier extends StateNotifier<double> {
  FontScaleNotifier() : super(1.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_fontScaleKey) ?? 1.0;
  }

  Future<void> setScale(double scale) async {
    state = scale.clamp(0.85, 1.3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, state);
  }

  void decrement() {
    if (state > 0.85) {
      final next = state == 1.0 ? 0.85 : (state == 1.2 ? 1.0 : 0.85);
      setScale(next);
    }
  }

  void increment() {
    if (state < 1.3) {
      final next = state == 0.85 ? 1.0 : (state == 1.0 ? 1.2 : 1.3);
      setScale(next);
    }
  }

  FontScalePreset get preset {
    if (state <= 0.9) return FontScalePreset.small;
    if (state <= 1.1) return FontScalePreset.medium;
    return FontScalePreset.large;
  }
}

final fontScaleProvider = StateNotifierProvider<FontScaleNotifier, double>((ref) {
  return FontScaleNotifier();
});
