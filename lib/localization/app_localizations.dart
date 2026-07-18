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

  /// No description provided for @onboardingDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Apps'**
  String get onboardingDiscoverTitle;

  /// No description provided for @onboardingDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the newest mobile apps and discover your favorites.'**
  String get onboardingDiscoverSubtitle;

  /// No description provided for @onboardingFeatureNewApps.
  ///
  /// In en, this message translates to:
  /// **'New applications'**
  String get onboardingFeatureNewApps;

  /// No description provided for @onboardingFeatureRealReviews.
  ///
  /// In en, this message translates to:
  /// **'Real user reviews'**
  String get onboardingFeatureRealReviews;

  /// No description provided for @onboardingFeatureDailyDiscoveries.
  ///
  /// In en, this message translates to:
  /// **'Daily discoveries'**
  String get onboardingFeatureDailyDiscoveries;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Your Experience'**
  String get onboardingReviewTitle;

  /// No description provided for @onboardingReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the apps you use, leave reviews, and help other users make better choices.'**
  String get onboardingReviewSubtitle;

  /// No description provided for @onboardingFeatureTrustedRatings.
  ///
  /// In en, this message translates to:
  /// **'Trusted ratings'**
  String get onboardingFeatureTrustedRatings;

  /// No description provided for @onboardingFeatureCommunityExperience.
  ///
  /// In en, this message translates to:
  /// **'Community experience'**
  String get onboardingFeatureCommunityExperience;

  /// No description provided for @onboardingShareExperience.
  ///
  /// In en, this message translates to:
  /// **'Share Your Experience'**
  String get onboardingShareExperience;

  /// No description provided for @onboardingReviewCommentOne.
  ///
  /// In en, this message translates to:
  /// **'Great design and very useful.'**
  String get onboardingReviewCommentOne;

  /// No description provided for @onboardingReviewCommentTwo.
  ///
  /// In en, this message translates to:
  /// **'The interface is very successful.'**
  String get onboardingReviewCommentTwo;

  /// No description provided for @onboardingReviewCommentThree.
  ///
  /// In en, this message translates to:
  /// **'I definitely recommend it.'**
  String get onboardingReviewCommentThree;

  /// No description provided for @onboardingHelpfulCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} people found this helpful'**
  String onboardingHelpfulCount(int count);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

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

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get navLeaderboard;

  /// No description provided for @navShowcase.
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get navShowcase;

  /// No description provided for @showcaseComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Showcase Coming Soon'**
  String get showcaseComingSoonTitle;

  /// No description provided for @showcaseComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Very soon, we will help your apps reach more people.'**
  String get showcaseComingSoonMessage;

  /// No description provided for @showcaseComingSoonBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium visibility is being prepared'**
  String get showcaseComingSoonBadge;

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

  /// No description provided for @authNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get authNewPasswordLabel;

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

  /// No description provided for @authOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION CODE'**
  String get authOtpLabel;

  /// No description provided for @authOtpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get authOtpHint;

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

  /// No description provided for @loginIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'EMAIL OR USERNAME'**
  String get loginIdentifierLabel;

  /// No description provided for @loginIdentifierHint.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get loginIdentifierHint;

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

  /// No description provided for @favoritesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You have not liked any apps yet.'**
  String get favoritesEmptyMessage;

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
  /// **'Already have an account?'**
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

  /// No description provided for @discoverWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get discoverWelcomeTitle;

  /// No description provided for @discoverWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Apps selected for you\nto discover today.'**
  String get discoverWelcomeSubtitle;

  /// No description provided for @discoverNewDrops.
  ///
  /// In en, this message translates to:
  /// **'New Drops'**
  String get discoverNewDrops;

  /// No description provided for @discoverDailyDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Daily Discovery'**
  String get discoverDailyDiscovery;

  /// No description provided for @discoverNewLabel.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get discoverNewLabel;

  /// No description provided for @discoverWeeklyDropsTitle.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Drops 👑'**
  String get discoverWeeklyDropsTitle;

  /// No description provided for @discoverWeeklyDropsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The apps highlighted most by the community.'**
  String get discoverWeeklyDropsSubtitle;

  /// No description provided for @discoverCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Recommendations'**
  String get discoverCommunityTitle;

  /// No description provided for @discoverReviewerBadge.
  ///
  /// In en, this message translates to:
  /// **'Top Reviewer'**
  String get discoverReviewerBadge;

  /// No description provided for @discoverPlaceholderReview.
  ///
  /// In en, this message translates to:
  /// **'Community reviews will appear here soon.'**
  String get discoverPlaceholderReview;

  /// No description provided for @discoverEmptyDropTitle.
  ///
  /// In en, this message translates to:
  /// **'A new Drop is being prepared'**
  String get discoverEmptyDropTitle;

  /// No description provided for @discoverEmptyDropMessage.
  ///
  /// In en, this message translates to:
  /// **'The next collection is being curated. Featured applications will appear here when it goes live.'**
  String get discoverEmptyDropMessage;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard data is being prepared'**
  String get leaderboardEmptyTitle;

  /// No description provided for @leaderboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The most prominent applications will appear here as new engagement arrives.'**
  String get leaderboardEmptyMessage;

  /// No description provided for @discoverBannerTimer.
  ///
  /// In en, this message translates to:
  /// **'End time coming soon'**
  String get discoverBannerTimer;

  /// No description provided for @dropFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'A description for this Drop is coming soon.'**
  String get dropFallbackDescription;

  /// No description provided for @dropEnded.
  ///
  /// In en, this message translates to:
  /// **'Drop ended'**
  String get dropEnded;

  /// No description provided for @dropCountdown.
  ///
  /// In en, this message translates to:
  /// **'Ends in {duration}'**
  String dropCountdown(String duration);

  /// No description provided for @discoverReviewButton.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get discoverReviewButton;

  /// No description provided for @dropTab.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get dropTab;

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
  /// **'Open in App Store'**
  String get detailOpenStore;

  /// No description provided for @detailCreatedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get detailCreatedBy;

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

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have any notifications yet.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationUnread.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationUnread;

  /// No description provided for @submitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to introduce a new digital experience? Fill in the details and start getting discovered.'**
  String get submitSubtitle;

  /// No description provided for @submitName.
  ///
  /// In en, this message translates to:
  /// **'Application name'**
  String get submitName;

  /// No description provided for @submitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION NAME'**
  String get submitNameLabel;

  /// No description provided for @submitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: SuperApp'**
  String get submitNameHint;

  /// No description provided for @submitCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get submitCategory;

  /// No description provided for @submitCategoryGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get submitCategoryGame;

  /// No description provided for @submitCategoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get submitCategoryFinance;

  /// No description provided for @submitCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get submitCategoryEducation;

  /// No description provided for @submitDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get submitDescription;

  /// No description provided for @submitDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What core value does your app provide?'**
  String get submitDescriptionHint;

  /// No description provided for @submitVideoUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get submitVideoUrl;

  /// No description provided for @submitVideoUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://youtube.com/...'**
  String get submitVideoUrlHint;

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

  /// No description provided for @submitScreenshotsLabel.
  ///
  /// In en, this message translates to:
  /// **'SCREENSHOTS (3-5)'**
  String get submitScreenshotsLabel;

  /// No description provided for @submitPickScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Pick image'**
  String get submitPickScreenshots;

  /// No description provided for @submitScreenshotSizeError.
  ///
  /// In en, this message translates to:
  /// **'Each screenshot must be at most 2 MB.'**
  String get submitScreenshotSizeError;

  /// No description provided for @submitScreenshotRequirements.
  ///
  /// In en, this message translates to:
  /// **'Choose 3 to 5 screenshots. Each one can be at most 2 MB.'**
  String get submitScreenshotRequirements;

  /// No description provided for @submitScreenshotCountError.
  ///
  /// In en, this message translates to:
  /// **'Choose at least 3 and at most 5 screenshots.'**
  String get submitScreenshotCountError;

  /// No description provided for @submitScreenshotLimitPrefix.
  ///
  /// In en, this message translates to:
  /// **'Maximum screenshot count:'**
  String get submitScreenshotLimitPrefix;

  /// No description provided for @submitPlatform.
  ///
  /// In en, this message translates to:
  /// **'PLATFORM'**
  String get submitPlatform;

  /// No description provided for @submitStoreLinks.
  ///
  /// In en, this message translates to:
  /// **'STORE LINKS'**
  String get submitStoreLinks;

  /// No description provided for @submitBothPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get submitBothPlatforms;

  /// No description provided for @submitApplyDrop.
  ///
  /// In en, this message translates to:
  /// **'Apply to Drop'**
  String get submitApplyDrop;

  /// No description provided for @submitRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in the application name and description.'**
  String get submitRequiredFields;

  /// No description provided for @submitFieldIsRequiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'is required.'**
  String get submitFieldIsRequiredSuffix;

  /// No description provided for @submitInvalidUrlSuffix.
  ///
  /// In en, this message translates to:
  /// **'must be a valid URL.'**
  String get submitInvalidUrlSuffix;

  /// No description provided for @submitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Application sent for review.'**
  String get submitSuccess;

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

  /// No description provided for @profilePromoteApp.
  ///
  /// In en, this message translates to:
  /// **'Promote My App'**
  String get profilePromoteApp;

  /// No description provided for @profilePromoteSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get profilePromoteSoonTitle;

  /// No description provided for @profilePromoteSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Very soon, we will open new promotion options that help your applications reach more people. Once everything is ready, you will be able to start directly from your profile.'**
  String get profilePromoteSoonMessage;

  /// No description provided for @profileCommentsTodo.
  ///
  /// In en, this message translates to:
  /// **'Comments cannot be loaded right now.'**
  String get profileCommentsTodo;

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

  /// No description provided for @profileCommentOwn.
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get profileCommentOwn;

  /// No description provided for @profileCommentReceived.
  ///
  /// In en, this message translates to:
  /// **'Comment on your app'**
  String get profileCommentReceived;

  /// No description provided for @profileCommentOwnApp.
  ///
  /// In en, this message translates to:
  /// **'Your comment on your app'**
  String get profileCommentOwnApp;

  /// No description provided for @userProfilePublishedApps.
  ///
  /// In en, this message translates to:
  /// **'Published Apps'**
  String get userProfilePublishedApps;

  /// No description provided for @userProfileNoApps.
  ///
  /// In en, this message translates to:
  /// **'No published apps yet.'**
  String get userProfileNoApps;

  /// No description provided for @profileAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get profileAvatarTitle;

  /// No description provided for @profileAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar for your profile photo.'**
  String get profileAvatarSubtitle;

  /// No description provided for @profileAvatarSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileAvatarSave;

  /// No description provided for @profileAvatarSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get profileAvatarSaving;

  /// No description provided for @profileAvatarSaved.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated.'**
  String get profileAvatarSaved;

  /// No description provided for @profileAvatarEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no selectable avatars yet.'**
  String get profileAvatarEmpty;

  /// No description provided for @profileAvatarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Avatars cannot be loaded right now.'**
  String get profileAvatarLoadError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your app experience.'**
  String get settingsSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Application language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsNotifications;

  /// No description provided for @settingsSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification and application sounds'**
  String get settingsSoundSubtitle;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsVibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsVibrationSubtitle;

  /// No description provided for @settingsRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get settingsRateApp;

  /// No description provided for @settingsRateAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rate us on the App Store or Google Play.'**
  String get settingsRateAppSubtitle;

  /// No description provided for @settingsRateError.
  ///
  /// In en, this message translates to:
  /// **'The app store could not be opened.'**
  String get settingsRateError;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark appearance'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsSoon;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get settingsComingSoon;

  /// No description provided for @settingsDarkModeMessage.
  ///
  /// In en, this message translates to:
  /// **'Dark mode is coming soon.'**
  String get settingsDarkModeMessage;

  /// No description provided for @settingsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsOn;

  /// No description provided for @settingsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsOff;

  /// No description provided for @onboardingRewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish Your App, Reach the Top'**
  String get onboardingRewardsTitle;

  /// No description provided for @onboardingRewardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your app with the Firstlook community. Rise through the weekly app leaderboard as you earn likes and reach more people.'**
  String get onboardingRewardsSubtitle;

  /// No description provided for @onboardingFeatureLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Publish Your App'**
  String get onboardingFeatureLeaderboard;

  /// No description provided for @onboardingFeatureBadges.
  ///
  /// In en, this message translates to:
  /// **'Earn Likes'**
  String get onboardingFeatureBadges;

  /// No description provided for @onboardingFeatureDailyTasks.
  ///
  /// In en, this message translates to:
  /// **'Climb the Leaderboard'**
  String get onboardingFeatureDailyTasks;

  /// No description provided for @onboardingStartDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Submit Your App'**
  String get onboardingStartDiscovering;

  /// No description provided for @onboardingAchievementLeader.
  ///
  /// In en, this message translates to:
  /// **'App of the Week'**
  String get onboardingAchievementLeader;

  /// No description provided for @onboardingAchievementBadge.
  ///
  /// In en, this message translates to:
  /// **'Rising Fast'**
  String get onboardingAchievementBadge;

  /// No description provided for @onboardingAchievementActive.
  ///
  /// In en, this message translates to:
  /// **'New App'**
  String get onboardingAchievementActive;

  /// No description provided for @onboardingAppLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'App Leaderboard'**
  String get onboardingAppLeaderboard;

  /// No description provided for @onboardingLikesLabel.
  ///
  /// In en, this message translates to:
  /// **'likes'**
  String get onboardingLikesLabel;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search apps or users'**
  String get searchHint;

  /// No description provided for @searchMinCharacters.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 3 characters to see results.'**
  String get searchMinCharacters;

  /// No description provided for @searchApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get searchApplications;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get searchUsers;

  /// No description provided for @searchUsersTodo.
  ///
  /// In en, this message translates to:
  /// **'User search is not available right now.'**
  String get searchUsersTodo;

  /// No description provided for @developerPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'If you are a developer, create an account to submit your app.'**
  String get developerPromptTitle;

  /// No description provided for @developerPromptRegister.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get developerPromptRegister;

  /// No description provided for @developerPromptContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue Discovering'**
  String get developerPromptContinue;
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
