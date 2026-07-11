import 'package:firstlook/core/storage/hive_service.dart';
import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, bool>(
  (Ref ref) => OnboardingController(),
);

final developerOnboardingPromptProvider = StateProvider<bool>(
  (Ref ref) => false,
);

class OnboardingController extends StateNotifier<bool> {
  OnboardingController()
      : super(
          HiveService.preferencesBox.get(
            LocalStorageKeys.onboardingCompleted,
            defaultValue: false,
          ) as bool,
        );

  Future<void> complete() async {
    if (state) {
      return;
    }

    await HiveService.preferencesBox.put(
      LocalStorageKeys.onboardingCompleted,
      true,
    );
    state = true;
  }
}
