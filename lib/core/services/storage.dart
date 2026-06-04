import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 앱 전체에서 공유하는 보안 저장소 싱글턴
class AppStorage {
  static const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked,
    ),
  );
}
