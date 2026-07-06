import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FirstLook'**
  String get appName;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get commonNoData;

  /// No description provided for @commonUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonUnexpectedError;

  /// No description provided for @commonSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get commonSessionExpired;

  /// No description provided for @navDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get navDiscover;

  /// No description provided for @navSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get navSubmit;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @authDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Apps'**
  String get authDiscoverTitle;

  /// No description provided for @authDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover new games and apps early, try them first and leave a comment.'**
  String get authDiscoverSubtitle;

  /// No description provided for @authEmailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get authEmailAddressLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordConfirmationLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get authPasswordConfirmationLabel;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get authFullNameLabel;

  /// No description provided for @authRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get authRegisterCta;

  /// No description provided for @authLoginCta.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get authLoginCta;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'johndoe@mail.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get loginPasswordHint;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get registerNameHint;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @authFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get authFullNameRequired;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get authPasswordMismatch;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @screenArchitectureReady.
  ///
  /// In en, this message translates to:
  /// **'Architecture ready for feature development.'**
  String get screenArchitectureReady;

  /// No description provided for @submitTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit App'**
  String get submitTitle;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Discover mobile products first'**
  String get splashTagline;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join FirstLook and start exploring.'**
  String get registerSubtitle;

  /// No description provided for @authFirstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get authLastName;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authBiography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get authBiography;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authOtp.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authOtp;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email.'**
  String get otpSubtitle;

  /// No description provided for @otpButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send a reset code to your email.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPasswordButton;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @goToRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get goToRegister;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get goToLogin;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week: Mobile Apps'**
  String get discoverTitle;

  /// No description provided for @discoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverSubtitle;

  /// No description provided for @dropTab.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get dropTab;

  /// No description provided for @testTab.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testTab;

  /// No description provided for @iosTab.
  ///
  /// In en, this message translates to:
  /// **'iOS'**
  String get iosTab;

  /// No description provided for @androidTab.
  ///
  /// In en, this message translates to:
  /// **'Android'**
  String get androidTab;

  /// No description provided for @allPlatformsTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPlatformsTab;

  /// No description provided for @detailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get detailAbout;

  /// No description provided for @detailComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get detailComments;

  /// No description provided for @detailOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Open store'**
  String get detailOpenStore;

  /// No description provided for @detailJoinBeta.
  ///
  /// In en, this message translates to:
  /// **'Join beta'**
  String get detailJoinBeta;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get commentHint;

  /// No description provided for @commentSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commentSend;

  /// No description provided for @favoritesMissingEndpointTitle.
  ///
  /// In en, this message translates to:
  /// **'Liked apps'**
  String get favoritesMissingEndpointTitle;

  /// No description provided for @favoritesMissingEndpointBody.
  ///
  /// In en, this message translates to:
  /// **'TODO: API does not expose a liked-apps endpoint yet.'**
  String get favoritesMissingEndpointBody;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMissingEndpointBody.
  ///
  /// In en, this message translates to:
  /// **'TODO: API does not expose a mobile notifications endpoint yet.'**
  String get notificationsMissingEndpointBody;

  /// No description provided for @notificationUnread.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationUnread;

  /// No description provided for @submitName.
  ///
  /// In en, this message translates to:
  /// **'Application name'**
  String get submitName;

  /// No description provided for @submitCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get submitCategory;

  /// No description provided for @submitDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get submitDescription;

  /// No description provided for @submitVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get submitVideoUrl;

  /// No description provided for @submitAppStoreUrl.
  ///
  /// In en, this message translates to:
  /// **'App Store URL'**
  String get submitAppStoreUrl;

  /// No description provided for @submitGooglePlayUrl.
  ///
  /// In en, this message translates to:
  /// **'Google Play URL'**
  String get submitGooglePlayUrl;

  /// No description provided for @submitDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get submitDestination;

  /// No description provided for @submitScreenshotsTodo.
  ///
  /// In en, this message translates to:
  /// **'TODO: screenshot picker and multipart upload are wired to API shape next.'**
  String get submitScreenshotsTodo;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitButton;

  /// No description provided for @profileMyApps.
  ///
  /// In en, this message translates to:
  /// **'My applications'**
  String get profileMyApps;

  /// No description provided for @profileMyComments.
  ///
  /// In en, this message translates to:
  /// **'My comments'**
  String get profileMyComments;

  /// No description provided for @profileStatsApps.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get profileStatsApps;

  /// No description provided for @profileStatsLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get profileStatsLikes;

  /// No description provided for @profileStatsComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get profileStatsComments;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
