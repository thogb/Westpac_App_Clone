import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthController {
  final LocalAuthentication localAuthentication;

  static final LocalAuthController _localAuthController =
      LocalAuthController._();

  bool supportFingerPrintLogin = false;

  LocalAuthController._() : localAuthentication = LocalAuthentication();

  static LocalAuthController get instance => _localAuthController;

  Future<void> getDeviceInfo() async {
    late List<BiometricType> availableBiometrics;

    try {
      availableBiometrics = await localAuthentication.getAvailableBiometrics();

      supportFingerPrintLogin =
          availableBiometrics.contains(BiometricType.fingerprint);
    } on PlatformException {
      supportFingerPrintLogin = false;
    }
  }
}
