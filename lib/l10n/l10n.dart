import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_de.dart';
import 'l10n_en.dart';
import 'l10n_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('de'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @createYourDadaduID.
  ///
  /// In en, this message translates to:
  /// **'Create your Dadadu ID 🚀'**
  String get createYourDadaduID;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👽'**
  String get welcomeBack;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignUp;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number (with +country code)'**
  String get invalidPhone;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericError;

  /// No description provided for @welcomeToDadadu.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dadadu'**
  String get welcomeToDadadu;

  /// No description provided for @welcomeSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get welcomeSignUp;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get welcomeLogin;

  /// No description provided for @navNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get navNow;

  /// No description provided for @navUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get navUpload;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @feedPersonalizing.
  ///
  /// In en, this message translates to:
  /// **'Personalizing your feed...'**
  String get feedPersonalizing;

  /// No description provided for @feedAnalyzingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your preferences'**
  String get feedAnalyzingPreferences;

  /// No description provided for @noVideos.
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideos;

  /// No description provided for @followCreators.
  ///
  /// In en, this message translates to:
  /// **'Follow creators to see their content'**
  String get followCreators;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @nowLabel.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get nowLabel;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @noMatchesFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'No matches found nearby'**
  String get noMatchesFoundNearby;

  /// No description provided for @tryChangingIntentOrLater.
  ///
  /// In en, this message translates to:
  /// **'Try changing your intent or check back later'**
  String get tryChangingIntentOrLater;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @scanningForConnections.
  ///
  /// In en, this message translates to:
  /// **'Scanning for connections...'**
  String get scanningForConnections;

  /// No description provided for @lookingForIntentNearby.
  ///
  /// In en, this message translates to:
  /// **'Looking for {intent} nearby'**
  String lookingForIntentNearby(Object intent);

  /// No description provided for @cancelSearch.
  ///
  /// In en, this message translates to:
  /// **'Cancel Search'**
  String get cancelSearch;

  /// No description provided for @whatsYourVibe.
  ///
  /// In en, this message translates to:
  /// **'What\'s your vibe today?'**
  String get whatsYourVibe;

  /// No description provided for @locationPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'📍 Location access needed for matching nearby users'**
  String get locationPermissionNeeded;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission required for matching'**
  String get locationPermissionRequired;

  /// No description provided for @interestSentWaiting.
  ///
  /// In en, this message translates to:
  /// **'Interest sent! Waiting for response...'**
  String get interestSentWaiting;

  /// No description provided for @mutualMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 Mutual Match!'**
  String get mutualMatchTitle;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact for matches'**
  String get contactLabel;

  /// No description provided for @noContactInfo.
  ///
  /// In en, this message translates to:
  /// **'No contact info'**
  String get noContactInfo;

  /// No description provided for @greatButton.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get greatButton;

  /// No description provided for @interestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to express interest'**
  String get interestFailed;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @matchFound.
  ///
  /// In en, this message translates to:
  /// **'{emoji} Match Found!'**
  String matchFound(Object emoji);

  /// No description provided for @perfectMatch.
  ///
  /// In en, this message translates to:
  /// **'Perfect Match'**
  String get perfectMatch;

  /// No description provided for @greatMatch.
  ///
  /// In en, this message translates to:
  /// **'Great Match'**
  String get greatMatch;

  /// No description provided for @goodMatch.
  ///
  /// In en, this message translates to:
  /// **'Good Match'**
  String get goodMatch;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'{emoji} {mood}'**
  String mood(Object emoji, Object mood);

  /// No description provided for @away.
  ///
  /// In en, this message translates to:
  /// **'{distance}m away'**
  String away(Object distance);

  /// No description provided for @diamonds.
  ///
  /// In en, this message translates to:
  /// **'{count} diamonds'**
  String diamonds(Object count);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @interested.
  ///
  /// In en, this message translates to:
  /// **'I\'m Interested'**
  String get interested;

  /// No description provided for @enterOtpMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone'**
  String get enterOtpMessage;

  /// No description provided for @otpHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpHint;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @otpError.
  ///
  /// In en, this message translates to:
  /// **'OTP incorrect. Please try again.'**
  String get otpError;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImage;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @cropFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to crop image'**
  String get cropFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @noImageLoaded.
  ///
  /// In en, this message translates to:
  /// **'No image loaded'**
  String get noImageLoaded;

  /// No description provided for @loadingImage.
  ///
  /// In en, this message translates to:
  /// **'Loading image...'**
  String get loadingImage;

  /// No description provided for @imageReady.
  ///
  /// In en, this message translates to:
  /// **'Image ready!'**
  String get imageReady;

  /// No description provided for @cropping.
  ///
  /// In en, this message translates to:
  /// **'Cropping...'**
  String get cropping;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @cropAndSave.
  ///
  /// In en, this message translates to:
  /// **'Crop & Save'**
  String get cropAndSave;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @moodProfile.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodProfile;

  /// No description provided for @howBadgesWork.
  ///
  /// In en, this message translates to:
  /// **'How Badges Work'**
  String get howBadgesWork;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @noMatchHistory.
  ///
  /// In en, this message translates to:
  /// **'No match history.'**
  String get noMatchHistory;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match History'**
  String get matchHistory;

  /// No description provided for @matchedWith.
  ///
  /// In en, this message translates to:
  /// **'Matched with'**
  String get matchedWith;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @intent.
  ///
  /// In en, this message translates to:
  /// **'Intent'**
  String get intent;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @followingStatus.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingStatus;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @diamondsProfile.
  ///
  /// In en, this message translates to:
  /// **'Diamonds'**
  String get diamondsProfile;

  /// No description provided for @myVideos.
  ///
  /// In en, this message translates to:
  /// **'My Videos'**
  String get myVideos;

  /// No description provided for @videosOf.
  ///
  /// In en, this message translates to:
  /// **'Videos of'**
  String get videosOf;

  /// No description provided for @badgeMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Badge Marketplace'**
  String get badgeMarketplace;

  /// No description provided for @referFriends.
  ///
  /// In en, this message translates to:
  /// **'Refer Friends'**
  String get referFriends;

  /// No description provided for @referralDescription.
  ///
  /// In en, this message translates to:
  /// **'Earn 100 diamonds for every friend who joins Dadadu with your code!'**
  String get referralDescription;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// No description provided for @newUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsernameHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @referralLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral link copied! 📋'**
  String get referralLinkCopied;

  /// No description provided for @shareProfileText.
  ///
  /// In en, this message translates to:
  /// **'🎬 Check out {username}’s profile on Dadadu!\nAn app for authentic short videos without likes or views.\n{profileUrl}\n\n#Dadadu #Profile'**
  String shareProfileText(Object profileUrl, Object username);

  /// No description provided for @shareProfileSubject.
  ///
  /// In en, this message translates to:
  /// **'{username}’s Dadadu Profile'**
  String shareProfileSubject(Object username);

  /// No description provided for @shareProfileError.
  ///
  /// In en, this message translates to:
  /// **'Error while sharing: {error}'**
  String shareProfileError(Object error);

  /// No description provided for @shareReferralText.
  ///
  /// In en, this message translates to:
  /// **'🎬 Join me on Dadadu! A short video app with no likes, just realness. Use my referral link to earn 100 💎: {referralLink}\n\n#Dadadu #Authentic #NoViews'**
  String shareReferralText(Object referralLink);

  /// No description provided for @shareReferralSubject.
  ///
  /// In en, this message translates to:
  /// **'Join me on Dadadu!'**
  String get shareReferralSubject;

  /// No description provided for @listingRemoved.
  ///
  /// In en, this message translates to:
  /// **'Listing removed'**
  String get listingRemoved;

  /// No description provided for @errorRemovingListing.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorRemovingListing(Object error);

  /// No description provided for @notEnoughDiamonds.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough diamonds!'**
  String get notEnoughDiamonds;

  /// No description provided for @badgePurchased.
  ///
  /// In en, this message translates to:
  /// **'Badge purchased successfully!'**
  String get badgePurchased;

  /// No description provided for @badgePurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String badgePurchaseError(Object error);

  /// No description provided for @badgeListed.
  ///
  /// In en, this message translates to:
  /// **'Badge listed successfully!'**
  String get badgeListed;

  /// No description provided for @badgeListingError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String badgeListingError(Object error);

  /// No description provided for @sellBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell your badge'**
  String get sellBadgeTitle;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price in diamonds'**
  String get priceLabel;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'Suggested price: {price} 💎'**
  String priceHint(Object price);

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @sellCurrentBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell my current badge'**
  String get sellCurrentBadgeTitle;

  /// No description provided for @sellButton.
  ///
  /// In en, this message translates to:
  /// **'List for sale'**
  String get sellButton;

  /// No description provided for @ownBadgeSellError.
  ///
  /// In en, this message translates to:
  /// **'You can only sell your own badges'**
  String get ownBadgeSellError;

  /// No description provided for @myBadgesForSale.
  ///
  /// In en, this message translates to:
  /// **'My badges for sale'**
  String get myBadgesForSale;

  /// No description provided for @noBadgesForSale.
  ///
  /// In en, this message translates to:
  /// **'No badges for sale'**
  String get noBadgesForSale;

  /// No description provided for @buyForDiamonds.
  ///
  /// In en, this message translates to:
  /// **'Buy {diamonds} 💎'**
  String buyForDiamonds(Object diamonds);

  /// No description provided for @yourBadge.
  ///
  /// In en, this message translates to:
  /// **'Your badge'**
  String get yourBadge;

  /// No description provided for @badgeSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'🏆 DADADU BADGE SYSTEM'**
  String get badgeSystemTitle;

  /// No description provided for @badgeLeafTitle.
  ///
  /// In en, this message translates to:
  /// **'LEAF (0–9,999 diamonds)'**
  String get badgeLeafTitle;

  /// No description provided for @badgeLeafDesc.
  ///
  /// In en, this message translates to:
  /// **'Starting level for new users'**
  String get badgeLeafDesc;

  /// No description provided for @badgeThreeleafTitle.
  ///
  /// In en, this message translates to:
  /// **'THREELEAF (10K–999K)'**
  String get badgeThreeleafTitle;

  /// No description provided for @badgeThreeleafDesc.
  ///
  /// In en, this message translates to:
  /// **'Active community member'**
  String get badgeThreeleafDesc;

  /// No description provided for @badgeFiveleafTitle.
  ///
  /// In en, this message translates to:
  /// **'FIVELEAF (1M–9.9M)'**
  String get badgeFiveleafTitle;

  /// No description provided for @badgeFiveleafDesc.
  ///
  /// In en, this message translates to:
  /// **'Popular creator status'**
  String get badgeFiveleafDesc;

  /// No description provided for @badgeDadalordTitle.
  ///
  /// In en, this message translates to:
  /// **'DADALORD (10M+)'**
  String get badgeDadalordTitle;

  /// No description provided for @badgeDadalordDesc.
  ///
  /// In en, this message translates to:
  /// **'Elite status worth \\\$10,000+ with +2% per million diamonds'**
  String get badgeDadalordDesc;

  /// No description provided for @badgeNote.
  ///
  /// In en, this message translates to:
  /// **'📈 Higher badges = more prestige + marketplace value'**
  String get badgeNote;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @profilePhotoRemoved.
  ///
  /// In en, this message translates to:
  /// **'✅ Profile photo removed'**
  String get profilePhotoRemoved;

  /// No description provided for @profilePhotoRemoveError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error while removing profile photo'**
  String get profilePhotoRemoveError;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'✅ Profile photo updated'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoUpdateError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error uploading profile photo'**
  String get profilePhotoUpdateError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @userUnknown.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userUnknown;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @setupDiscover.
  ///
  /// In en, this message translates to:
  /// **'Configure Discover'**
  String get setupDiscover;

  /// No description provided for @intentWith.
  ///
  /// In en, this message translates to:
  /// **'Intent: {intent}'**
  String intentWith(Object intent);

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @notDefined.
  ///
  /// In en, this message translates to:
  /// **'Not defined'**
  String get notDefined;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @photoSet.
  ///
  /// In en, this message translates to:
  /// **'Photo set'**
  String get photoSet;

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhoto;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securitySection;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sendResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Send password reset email'**
  String get sendResetEmail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the app'**
  String get logoutDescription;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @discoverConfigUpdated.
  ///
  /// In en, this message translates to:
  /// **'🎯 Discover configuration updated'**
  String get discoverConfigUpdated;

  /// No description provided for @discoverConfigError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error while saving configuration'**
  String get discoverConfigError;

  /// No description provided for @discoverConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Configuration'**
  String get discoverConfigTitle;

  /// No description provided for @selectIntent.
  ///
  /// In en, this message translates to:
  /// **'Select your intent'**
  String get selectIntent;

  /// No description provided for @socialNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Social network'**
  String get socialNetworkLabel;

  /// No description provided for @identifierHint.
  ///
  /// In en, this message translates to:
  /// **'Your ID'**
  String get identifierHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @intentLove.
  ///
  /// In en, this message translates to:
  /// **'love'**
  String get intentLove;

  /// No description provided for @intentBusiness.
  ///
  /// In en, this message translates to:
  /// **'business'**
  String get intentBusiness;

  /// No description provided for @intentEntertainment.
  ///
  /// In en, this message translates to:
  /// **'entertainment'**
  String get intentEntertainment;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'📧 Reset email sent to {email}'**
  String resetEmailSent(Object email);

  /// No description provided for @resetEmailError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error sending the reset email'**
  String get resetEmailError;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error while selecting the image'**
  String get imageSelectionError;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @usernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'✅ Username updated'**
  String get usernameUpdated;

  /// No description provided for @usernameUpdateError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error updating username'**
  String get usernameUpdateError;

  /// No description provided for @changeUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get changeUsernameTitle;

  /// No description provided for @changeUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new name'**
  String get changeUsernameHint;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @trimTitle.
  ///
  /// In en, this message translates to:
  /// **'Trim Your Video'**
  String get trimTitle;

  /// No description provided for @trimContinue.
  ///
  /// In en, this message translates to:
  /// **'Trim and Continue'**
  String get trimContinue;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @shareBaseText.
  ///
  /// In en, this message translates to:
  /// **'🎬 Check out this video on Dadadu!\n\"{caption}\"\nBy @{username}\n\n📱 Authentic video app without likes or views\n#Dadadu #Authentic #Local'**
  String shareBaseText(Object caption, Object username);

  /// No description provided for @shareWhatsAppSuffix.
  ///
  /// In en, this message translates to:
  /// **'💎 Download Dadadu and earn diamonds!'**
  String get shareWhatsAppSuffix;

  /// No description provided for @shareInstagramSuffix.
  ///
  /// In en, this message translates to:
  /// **'📲 #DadaduApp #NoLikes #RealContent'**
  String get shareInstagramSuffix;

  /// No description provided for @shareFacebookSuffix.
  ///
  /// In en, this message translates to:
  /// **'🌟 Join the authentic content revolution!'**
  String get shareFacebookSuffix;

  /// No description provided for @shareSnapchatSuffix.
  ///
  /// In en, this message translates to:
  /// **'👻 No more algorithm, more real!'**
  String get shareSnapchatSuffix;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'❌ Storage permission required'**
  String get permissionRequired;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'📥 Downloading...'**
  String get downloading;

  /// No description provided for @videoSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Saved to Downloads!'**
  String get videoSaved;

  /// No description provided for @errorSavingVideo.
  ///
  /// In en, this message translates to:
  /// **'❌ Error saving video: {error}'**
  String errorSavingVideo(Object error);

  /// No description provided for @shareVideo.
  ///
  /// In en, this message translates to:
  /// **'📤 Share this video'**
  String get shareVideo;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @shareError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error sharing: {error}'**
  String shareError(Object error);

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {username}'**
  String replyingTo(Object username);

  /// No description provided for @replyToComment.
  ///
  /// In en, this message translates to:
  /// **'Reply to comment...'**
  String get replyToComment;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addComment;

  /// No description provided for @creator.
  ///
  /// In en, this message translates to:
  /// **'CREATOR'**
  String get creator;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @repliesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, one{reply} other{replies}}'**
  String repliesCount(num count);

  /// No description provided for @noCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment!'**
  String get noCommentsTitle;

  /// No description provided for @noCommentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts about this video'**
  String get noCommentsSubtitle;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'🕒 Recent'**
  String get sortRecent;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'🔥 Popular'**
  String get sortPopular;

  /// No description provided for @sortTrending.
  ///
  /// In en, this message translates to:
  /// **'📈 Trending'**
  String get sortTrending;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'💬 Comments'**
  String get commentsTitle;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentsCount(Object count);

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to comment'**
  String get mustBeLoggedIn;

  /// No description provided for @commentPosted.
  ///
  /// In en, this message translates to:
  /// **'💬 Comment posted!'**
  String get commentPosted;

  /// No description provided for @commentError.
  ///
  /// In en, this message translates to:
  /// **'Error sending comment'**
  String get commentError;

  /// No description provided for @newCommentNotification.
  ///
  /// In en, this message translates to:
  /// **'💬 New comment'**
  String get newCommentNotification;

  /// No description provided for @userCommented.
  ///
  /// In en, this message translates to:
  /// **'{username} commented on your video'**
  String userCommented(Object username);

  /// No description provided for @createVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Video'**
  String get createVideoTitle;

  /// No description provided for @createDadaduVideo.
  ///
  /// In en, this message translates to:
  /// **'Create your Dadadu video'**
  String get createDadaduVideo;

  /// No description provided for @maximum20Seconds.
  ///
  /// In en, this message translates to:
  /// **'Maximum 20 seconds'**
  String get maximum20Seconds;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your video...\nWhat do you want to share?'**
  String get captionHint;

  /// No description provided for @publishVideoButton.
  ///
  /// In en, this message translates to:
  /// **'PUBLISH VIDEO'**
  String get publishVideoButton;

  /// No description provided for @infoAddCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption to publish your video'**
  String get infoAddCaption;

  /// No description provided for @infoSelectOrRecord.
  ///
  /// In en, this message translates to:
  /// **'Select or record a video to get started'**
  String get infoSelectOrRecord;

  /// No description provided for @videoIntent.
  ///
  /// In en, this message translates to:
  /// **'Video Intent'**
  String get videoIntent;

  /// No description provided for @intentFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get intentFun;

  /// No description provided for @intentSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious'**
  String get intentSerious;

  /// No description provided for @intentInformative.
  ///
  /// In en, this message translates to:
  /// **'Informative'**
  String get intentInformative;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @noVideoSelected.
  ///
  /// In en, this message translates to:
  /// **'No video selected'**
  String get noVideoSelected;

  /// No description provided for @pleaseAddCaption.
  ///
  /// In en, this message translates to:
  /// **'Please add a caption'**
  String get pleaseAddCaption;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @userProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'User profile not found'**
  String get userProfileNotFound;

  /// No description provided for @videoPublishedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'🎉 Video published successfully!'**
  String get videoPublishedSuccessfully;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload error'**
  String get uploadError;

  /// No description provided for @stopRecordingError.
  ///
  /// In en, this message translates to:
  /// **'Stop recording error: {error}'**
  String stopRecordingError(Object error);

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Recording error: {error}'**
  String recordingError(Object error);

  /// No description provided for @selectionError.
  ///
  /// In en, this message translates to:
  /// **'Selection error: {error}'**
  String selectionError(Object error);

  /// No description provided for @videoLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Video loading error: {error}'**
  String videoLoadingError(Object error);
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return SDe();
    case 'en':
      return SEn();
    case 'fr':
      return SFr();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
