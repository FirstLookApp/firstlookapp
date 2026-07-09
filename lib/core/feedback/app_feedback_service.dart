import 'dart:async';

import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppFeedbackSettings {
  const AppFeedbackSettings({
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  final bool soundEnabled;
  final bool vibrationEnabled;

  AppFeedbackSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return AppFeedbackSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

abstract final class AppFeedbackService {
  static bool get soundEnabled => HiveService.preferencesBox
      .get(LocalStorageKeys.soundEnabled, defaultValue: true) as bool;

  static bool get vibrationEnabled => HiveService.preferencesBox
      .get(LocalStorageKeys.vibrationEnabled, defaultValue: true) as bool;

  static void selection() {
    if (soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    if (vibrationEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
  }
}

class AppFeedbackSettingsController extends StateNotifier<AppFeedbackSettings> {
  AppFeedbackSettingsController()
      : super(
          AppFeedbackSettings(
            soundEnabled: AppFeedbackService.soundEnabled,
            vibrationEnabled: AppFeedbackService.vibrationEnabled,
          ),
        );

  Future<void> setSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await HiveService.preferencesBox.put(LocalStorageKeys.soundEnabled, value);
    AppFeedbackService.selection();
  }

  Future<void> setVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await HiveService.preferencesBox.put(
      LocalStorageKeys.vibrationEnabled,
      value,
    );
    AppFeedbackService.selection();
  }
}

final appFeedbackSettingsProvider =
    StateNotifierProvider<AppFeedbackSettingsController, AppFeedbackSettings>(
  (Ref ref) => AppFeedbackSettingsController(),
);
