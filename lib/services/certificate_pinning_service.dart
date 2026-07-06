import 'dart:io';

class CertificatePinningService {
  const CertificatePinningService();

  void configure(HttpClient client) {
    // Production certificate pinning can be activated here by validating the
    // server certificate fingerprint or public key hash against bundled pins.
    client.badCertificateCallback = (
      X509Certificate cert,
      String host,
      int port,
    ) {
      return false;
    };
  }
}
