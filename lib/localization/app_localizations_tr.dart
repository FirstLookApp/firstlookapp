// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'FirstLook';

  @override
  String get commonRetry => 'Tekrar Dene';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonConfirm => 'Onayla';

  @override
  String get commonSearch => 'Ara';

  @override
  String get commonNoData => 'Veri bulunamadı';

  @override
  String get commonUnexpectedError =>
      'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get commonSessionExpired =>
      'Oturumunuz sona erdi. Lütfen yeniden giriş yapın.';

  @override
  String get navDiscover => 'Keşfet';

  @override
  String get navLeaderboard => 'Liderlik';

  @override
  String get navShowcase => 'Vitrin';

  @override
  String get showcaseComingSoonTitle => 'Vitrin Çok Yakında';

  @override
  String get showcaseComingSoonMessage =>
      'Çok yakında uygulamalarınızın daha fazla kişiye erişmesini sağlayacağız.';

  @override
  String get showcaseComingSoonBadge => 'Premium görünürlük hazırlanıyor';

  @override
  String get navSubmit => 'Gönder';

  @override
  String get navFavorites => 'Beğeniler';

  @override
  String get navProfile => 'Profil';

  @override
  String get loginTitle => 'Tekrar hoş geldiniz';

  @override
  String get loginSubtitle => 'Devam etmek için giriş yapın';

  @override
  String get loginEmail => 'E-posta';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginRememberMe => 'Beni hatırla';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get authDiscoverTitle => 'Uygulamalarını Keşfet';

  @override
  String get authDiscoverSubtitle =>
      'Yeni oyunları ve uygulamaları erken keşfet, ilk sen dene ve yorumla.';

  @override
  String get authEmailAddressLabel => 'E-POSTA ADRESİ';

  @override
  String get authPasswordLabel => 'ŞİFRE';

  @override
  String get authNewPasswordLabel => 'YENİ ŞİFRE';

  @override
  String get authPasswordConfirmationLabel => 'ŞİFRENİZİ ONAYLAYIN';

  @override
  String get authFullNameLabel => 'ADINIZ SOYADINIZ';

  @override
  String get authOtpLabel => 'DOĞRULAMA KODU';

  @override
  String get authOtpHint => '6 haneli kod';

  @override
  String get authRegisterCta => 'KAYIT OL';

  @override
  String get authLoginCta => 'GİRİŞ YAP';

  @override
  String get loginIdentifierLabel => 'E-POSTA VEYA KULLANICI ADI';

  @override
  String get loginIdentifierHint => 'E-posta veya kullanıcı adı';

  @override
  String get loginEmailHint => 'johndoe@mail.com';

  @override
  String get loginPasswordHint => 'Şifreniz';

  @override
  String get registerNameHint => 'John Doe';

  @override
  String get registerConfirmPasswordHint => 'Şifrenizi Onaylayın';

  @override
  String get authFullNameRequired => 'Adınız ve soyadınızı girin.';

  @override
  String get authPasswordMismatch => 'Şifreler eşleşmiyor.';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get logoutButton => 'Çıkış Yap';

  @override
  String get screenArchitectureReady => 'Mimari, özellik geliştirmeye hazır.';

  @override
  String get submitTitle => 'Uygulama Gönder';

  @override
  String get favoritesTitle => 'Beğeniler';

  @override
  String get favoritesEmptyMessage => 'Henüz hiçbir uygulamayı beğenmediniz.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get splashTagline => 'Mobil ürünleri ilk keşfeden sen ol';

  @override
  String get registerTitle => 'Hesap oluştur';

  @override
  String get registerSubtitle => 'FirstLook\'a katıl ve keşfetmeye başla.';

  @override
  String get authFirstName => 'Ad';

  @override
  String get authLastName => 'Soyad';

  @override
  String get authUsername => 'Kullanıcı adı';

  @override
  String get authBiography => 'Biyografi';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authNewPassword => 'Yeni şifre';

  @override
  String get authOtp => 'Doğrulama kodu';

  @override
  String get registerButton => 'Hesap oluştur';

  @override
  String get otpTitle => 'E-postanı doğrula';

  @override
  String get otpSubtitle => 'E-postana gelen 6 haneli kodu gir.';

  @override
  String get otpButton => 'Doğrula';

  @override
  String get forgotPasswordTitle => 'Şifremi unuttum';

  @override
  String get forgotPasswordSubtitle => 'E-postana sıfırlama kodu göndereceğiz.';

  @override
  String get forgotPasswordButton => 'Kod gönder';

  @override
  String get resetPasswordButton => 'Şifreyi sıfırla';

  @override
  String get goToRegister => 'Hesap oluştur';

  @override
  String get goToLogin => 'Zaten hesabınız var mı?';

  @override
  String get discoverTitle => 'Bu Hafta: Mobil Uygulamalar';

  @override
  String get discoverSubtitle => 'Keşfet';

  @override
  String get leaderboardTitle => 'Liderlik Tablosu';

  @override
  String get discoverBannerTimer => 'Bitiş tarihi yakında';

  @override
  String get dropFallbackDescription => 'Bu Drop için açıklama yakında.';

  @override
  String get dropEnded => 'Drop sona erdi';

  @override
  String dropCountdown(String duration) {
    return 'Bitişe $duration';
  }

  @override
  String get discoverReviewButton => 'İncele';

  @override
  String get dropTab => 'Drop';

  @override
  String get iosTab => 'iOS';

  @override
  String get androidTab => 'Android';

  @override
  String get allPlatformsTab => 'Tümü';

  @override
  String get detailAbout => 'Hakkında';

  @override
  String get detailComments => 'Yorumlar';

  @override
  String get detailOpenStore => 'Uygulama Mağazasında Aç';

  @override
  String get commentHint => 'Yorum yaz';

  @override
  String get commentSend => 'Gönder';

  @override
  String get notificationsTitle => 'Bildirimler';

  @override
  String get notificationsEmptyMessage =>
      'Henüz hiçbir bildiriminiz bulunmuyor.';

  @override
  String get notificationUnread => 'Yeni';

  @override
  String get submitSubtitle =>
      'Dünyaya yeni bir dijital deneyim sunmaya hazır mısın? Detayları doldur ve keşfedilmeye başla.';

  @override
  String get submitName => 'Uygulama adı';

  @override
  String get submitNameLabel => 'UYGULAMA ADI';

  @override
  String get submitNameHint => 'Örn: SuperApp';

  @override
  String get submitCategory => 'Kategori';

  @override
  String get submitCategoryGame => 'Oyun';

  @override
  String get submitCategoryFinance => 'Finans';

  @override
  String get submitCategoryEducation => 'Eğitim';

  @override
  String get submitDescription => 'Açıklama';

  @override
  String get submitDescriptionHint =>
      'Uygulamanın sunduğu temel değerler nelerdir?';

  @override
  String get submitVideoUrl => 'Video URL';

  @override
  String get submitVideoUrlHint => 'https://youtube.com/...';

  @override
  String get submitAppStoreUrl => 'App Store URL';

  @override
  String get submitGooglePlayUrl => 'Google Play URL';

  @override
  String get submitDestination => 'Hedef';

  @override
  String get submitScreenshotsLabel => 'EKRAN GÖRÜNTÜLERİ (MAKS. 5)';

  @override
  String get submitPickScreenshots => 'Görsel seç';

  @override
  String get submitScreenshotSizeError =>
      'Her ekran görüntüsü en fazla 2 MB olabilir.';

  @override
  String get submitScreenshotLimitPrefix => 'En fazla ekran görüntüsü sayısı:';

  @override
  String get submitPlatform => 'PLATFORM';

  @override
  String get submitStoreLinks => 'MAĞAZA LİNKLERİ';

  @override
  String get submitBothPlatforms => 'İkisi';

  @override
  String get submitApplyDrop => 'Drop\'a Başvur';

  @override
  String get submitRequiredFields =>
      'Uygulama adı ve açıklama alanlarını doldurun.';

  @override
  String get submitFieldIsRequiredSuffix => 'alanı zorunludur.';

  @override
  String get submitInvalidUrlSuffix => 'geçerli bir bağlantı olmalıdır.';

  @override
  String get submitSuccess => 'Uygulama incelemeye gönderildi.';

  @override
  String get submitButton => 'İncelemeye gönder';

  @override
  String get profileMyApps => 'Uygulamalarım';

  @override
  String get profileMyComments => 'Yorumlarım';

  @override
  String get profilePromoteApp => 'Uygulamanı Öne Çıkar';

  @override
  String get profilePromoteSoonTitle => 'Çok yakında';

  @override
  String get profilePromoteSoonMessage =>
      'Çok yakında uygulamalarınızın daha fazla kişiye ulaşmasını sağlayacak yeni öne çıkarma seçeneklerini açacağız. Hazırlıklar tamamlandığında profilinizden kolayca başlatabileceksiniz.';

  @override
  String get profileCommentsTodo => 'Yorumlar şu anda yüklenemiyor.';

  @override
  String get profileStatsApps => 'Uygulama';

  @override
  String get profileStatsLikes => 'Beğeni';

  @override
  String get profileStatsComments => 'Yorum';

  @override
  String get profileCommentOwn => 'Senin yorumun';

  @override
  String get profileCommentReceived => 'Uygulamana gelen yorum';

  @override
  String get profileCommentOwnApp => 'Kendi uygulamana yorumun';

  @override
  String get userProfilePublishedApps => 'Yayınlanan Uygulamalar';

  @override
  String get userProfileNoApps => 'Henüz yayınlanan uygulama yok.';

  @override
  String get profileAvatarTitle => 'Avatar Seç';

  @override
  String get profileAvatarSubtitle => 'Profil fotoğrafın için bir avatar seç.';

  @override
  String get profileAvatarSave => 'Kaydet';

  @override
  String get profileAvatarSaving => 'Kaydediliyor';

  @override
  String get profileAvatarSaved => 'Avatar güncellendi.';

  @override
  String get profileAvatarEmpty => 'Henüz seçilebilir avatar yok.';

  @override
  String get profileAvatarLoadError => 'Avatarlar şu anda yüklenemiyor.';

  @override
  String get settingsLanguage => 'Dil Seçeneği';

  @override
  String get settingsNotifications => 'Ses';

  @override
  String get settingsVibration => 'Titreşim';

  @override
  String get settingsOn => 'Açık';

  @override
  String get settingsOff => 'Kapalı';

  @override
  String get searchHint => 'Uygulama veya kullanıcı ara';

  @override
  String get searchMinCharacters =>
      'Sonuçları görmek için en az 3 karakter girin.';

  @override
  String get searchApplications => 'Uygulamalar';

  @override
  String get searchUsers => 'Kullanıcılar';

  @override
  String get searchUsersTodo => 'Kullanıcı araması şu anda kullanılamıyor.';
}
