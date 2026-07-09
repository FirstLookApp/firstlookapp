import 'package:firstlook/core/storage/local_storage_keys.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract final class HiveService {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(LocalStorageKeys.authBox);
    await Hive.openBox<dynamic>(LocalStorageKeys.preferencesBox);
  }

  static Box<dynamic> get authBox =>
      Hive.box<dynamic>(LocalStorageKeys.authBox);

  static Box<dynamic> get preferencesBox =>
      Hive.box<dynamic>(LocalStorageKeys.preferencesBox);
}
