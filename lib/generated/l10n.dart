// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Create your Dadadu ID 🚀`
  String get createYourDadaduID {
    return Intl.message(
      'Create your Dadadu ID 🚀',
      name: 'createYourDadaduID',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `SIGN UP`
  String get signUp {
    return Intl.message('SIGN UP', name: 'signUp', desc: '', args: []);
  }

  /// `Creating...`
  String get creating {
    return Intl.message('Creating...', name: 'creating', desc: '', args: []);
  }

  /// `Welcome back 👽`
  String get welcomeBack {
    return Intl.message(
      'Welcome back 👽',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `LOGIN`
  String get login {
    return Intl.message('LOGIN', name: 'login', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Don't have an account? Sign up`
  String get noAccountSignUp {
    return Intl.message(
      'Don\'t have an account? Sign up',
      name: 'noAccountSignUp',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid phone number (with +country code)`
  String get invalidPhone {
    return Intl.message(
      'Please enter a valid phone number (with +country code)',
      name: 'invalidPhone',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred. Please try again.`
  String get genericError {
    return Intl.message(
      'An error occurred. Please try again.',
      name: 'genericError',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Dadadu`
  String get welcomeToDadadu {
    return Intl.message(
      'Welcome to Dadadu',
      name: 'welcomeToDadadu',
      desc: '',
      args: [],
    );
  }
  /// `Your world of streaming, all in one place.`
  String get welcomeToDadaduSubHeader {
    return Intl.message(
      'Your world of streaming, all in one place.',
      name: 'welcomeToDadaduSubHeader',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get welcomeSignUpSubHeader {
    // return Intl.message('Just landed? Sign up right away!', name: 'welcomeSignUpSubHeader', desc: '', args: []);
    return Intl.message('Or,', name: 'welcomeSignUpSubHeader', desc: '', args: []);
  }

  /// `Sign Up`
  String get welcomeSignUp {
    return Intl.message('Sign Up', name: 'welcomeSignUp', desc: '', args: []);
  }

  /// `Log In`
  String get welcomeLogin {
    return Intl.message('Log In', name: 'welcomeLogin', desc: '', args: []);
  }

  /// `Now`
  String get navNow {
    return Intl.message('Now', name: 'navNow', desc: '', args: []);
  }

  /// `Upload`
  String get navUpload {
    return Intl.message('Upload', name: 'navUpload', desc: '', args: []);
  }

  /// `Profile`
  String get navProfile {
    return Intl.message('Profile', name: 'navProfile', desc: '', args: []);
  }

  /// `Personalizing your feed...`
  String get feedPersonalizing {
    return Intl.message(
      'Personalizing your feed...',
      name: 'feedPersonalizing',
      desc: '',
      args: [],
    );
  }

  /// `Analyzing your preferences`
  String get feedAnalyzingPreferences {
    return Intl.message(
      'Analyzing your preferences',
      name: 'feedAnalyzingPreferences',
      desc: '',
      args: [],
    );
  }

  /// `No videos available`
  String get noVideos {
    return Intl.message(
      'No videos available',
      name: 'noVideos',
      desc: '',
      args: [],
    );
  }

  /// `Follow creators to see their content`
  String get followCreators {
    return Intl.message(
      'Follow creators to see their content',
      name: 'followCreators',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Now`
  String get nowLabel {
    return Intl.message('Now', name: 'nowLabel', desc: '', args: []);
  }

  /// `Discover`
  String get discover {
    return Intl.message('Discover', name: 'discover', desc: '', args: []);
  }

  /// `No matches found nearby`
  String get noMatchesFoundNearby {
    return Intl.message(
      'No matches found nearby',
      name: 'noMatchesFoundNearby',
      desc: '',
      args: [],
    );
  }

  /// `Try changing your intent or check back later`
  String get tryChangingIntentOrLater {
    return Intl.message(
      'Try changing your intent or check back later',
      name: 'tryChangingIntentOrLater',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message('Try Again', name: 'tryAgain', desc: '', args: []);
  }

  /// `Scanning for connections...`
  String get scanningForConnections {
    return Intl.message(
      'Scanning for connections...',
      name: 'scanningForConnections',
      desc: '',
      args: [],
    );
  }

  /// `Looking for {intent} nearby`
  String lookingForIntentNearby(Object intent) {
    return Intl.message(
      'Looking for $intent nearby',
      name: 'lookingForIntentNearby',
      desc: '',
      args: [intent],
    );
  }

  /// `Cancel Search`
  String get cancelSearch {
    return Intl.message(
      'Cancel Search',
      name: 'cancelSearch',
      desc: '',
      args: [],
    );
  }

  /// `What's your vibe today?`
  String get whatsYourVibe {
    return Intl.message(
      'What\'s your vibe today?',
      name: 'whatsYourVibe',
      desc: '',
      args: [],
    );
  }

  /// `📍 Location access needed for matching nearby users`
  String get locationPermissionNeeded {
    return Intl.message(
      '📍 Location access needed for matching nearby users',
      name: 'locationPermissionNeeded',
      desc: '',
      args: [],
    );
  }

  /// `Location permission required for matching`
  String get locationPermissionRequired {
    return Intl.message(
      'Location permission required for matching',
      name: 'locationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Interest sent! Waiting for response...`
  String get interestSentWaiting {
    return Intl.message(
      'Interest sent! Waiting for response...',
      name: 'interestSentWaiting',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Mutual Match!`
  String get mutualMatchTitle {
    return Intl.message(
      '🎉 Mutual Match!',
      name: 'mutualMatchTitle',
      desc: '',
      args: [],
    );
  }

  /// `Contact for matches`
  String get contactLabel {
    return Intl.message(
      'Contact for matches',
      name: 'contactLabel',
      desc: '',
      args: [],
    );
  }

  /// `No contact info`
  String get noContactInfo {
    return Intl.message(
      'No contact info',
      name: 'noContactInfo',
      desc: '',
      args: [],
    );
  }

  /// `Great!`
  String get greatButton {
    return Intl.message('Great!', name: 'greatButton', desc: '', args: []);
  }

  /// `Failed to express interest`
  String get interestFailed {
    return Intl.message(
      'Failed to express interest',
      name: 'interestFailed',
      desc: '',
      args: [],
    );
  }

  /// `Search failed`
  String get searchFailed {
    return Intl.message(
      'Search failed',
      name: 'searchFailed',
      desc: '',
      args: [],
    );
  }

  /// `{emoji} Match Found!`
  String matchFound(Object emoji) {
    return Intl.message(
      '$emoji Match Found!',
      name: 'matchFound',
      desc: '',
      args: [emoji],
    );
  }

  /// `Perfect Match`
  String get perfectMatch {
    return Intl.message(
      'Perfect Match',
      name: 'perfectMatch',
      desc: '',
      args: [],
    );
  }

  /// `Great Match`
  String get greatMatch {
    return Intl.message('Great Match', name: 'greatMatch', desc: '', args: []);
  }

  /// `Good Match`
  String get goodMatch {
    return Intl.message('Good Match', name: 'goodMatch', desc: '', args: []);
  }

  /// `{emoji} {mood}`
  String mood(Object emoji, Object mood) {
    return Intl.message(
      '$emoji $mood',
      name: 'mood',
      desc: '',
      args: [emoji, mood],
    );
  }

  /// `{distance}m away`
  String away(Object distance) {
    return Intl.message(
      '${distance}m away',
      name: 'away',
      desc: '',
      args: [distance],
    );
  }

  /// `{count} diamonds`
  String diamonds(Object count) {
    return Intl.message(
      '$count diamonds',
      name: 'diamonds',
      desc: '',
      args: [count],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  /// `I'm Interested`
  String get interested {
    return Intl.message(
      'I\'m Interested',
      name: 'interested',
      desc: '',
      args: [],
    );
  }

  /// `Enter the OTP sent to your phone`
  String get enterOtpMessage {
    return Intl.message(
      'Enter the OTP sent to your phone',
      name: 'enterOtpMessage',
      desc: '',
      args: [],
    );
  }

  /// `6-digit code`
  String get otpHint {
    return Intl.message('6-digit code', name: 'otpHint', desc: '', args: []);
  }

  /// `Verify`
  String get verify {
    return Intl.message('Verify', name: 'verify', desc: '', args: []);
  }

  /// `OTP incorrect. Please try again.`
  String get otpError {
    return Intl.message(
      'OTP incorrect. Please try again.',
      name: 'otpError',
      desc: '',
      args: [],
    );
  }

  /// `Crop Image`
  String get cropImage {
    return Intl.message('Crop Image', name: 'cropImage', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Failed to crop image`
  String get cropFailed {
    return Intl.message(
      'Failed to crop image',
      name: 'cropFailed',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `No image loaded`
  String get noImageLoaded {
    return Intl.message(
      'No image loaded',
      name: 'noImageLoaded',
      desc: '',
      args: [],
    );
  }

  /// `Loading image...`
  String get loadingImage {
    return Intl.message(
      'Loading image...',
      name: 'loadingImage',
      desc: '',
      args: [],
    );
  }

  /// `Image ready!`
  String get imageReady {
    return Intl.message('Image ready!', name: 'imageReady', desc: '', args: []);
  }

  /// `Cropping...`
  String get cropping {
    return Intl.message('Cropping...', name: 'cropping', desc: '', args: []);
  }

  /// `Undo`
  String get undo {
    return Intl.message('Undo', name: 'undo', desc: '', args: []);
  }

  /// `Redo`
  String get redo {
    return Intl.message('Redo', name: 'redo', desc: '', args: []);
  }

  /// `Crop & Save`
  String get cropAndSave {
    return Intl.message('Crop & Save', name: 'cropAndSave', desc: '', args: []);
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Mood`
  String get moodProfile {
    return Intl.message('Mood', name: 'moodProfile', desc: '', args: []);
  }

  /// `How Badges Work`
  String get howBadgesWork {
    return Intl.message(
      'How Badges Work',
      name: 'howBadgesWork',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get followers {
    return Intl.message('Followers', name: 'followers', desc: '', args: []);
  }

  /// `Following`
  String get following {
    return Intl.message('Following', name: 'following', desc: '', args: []);
  }

  /// `Rank`
  String get rank {
    return Intl.message('Rank', name: 'rank', desc: '', args: []);
  }

  /// `No match history.`
  String get noMatchHistory {
    return Intl.message(
      'No match history.',
      name: 'noMatchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Match History`
  String get matchHistory {
    return Intl.message(
      'Match History',
      name: 'matchHistory',
      desc: '',
      args: [],
    );
  }

  /// `Matched with`
  String get matchedWith {
    return Intl.message(
      'Matched with',
      name: 'matchedWith',
      desc: '',
      args: [],
    );
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// `Intent`
  String get intent {
    return Intl.message('Intent', name: 'intent', desc: '', args: []);
  }

  /// `Follow`
  String get follow {
    return Intl.message('Follow', name: 'follow', desc: '', args: []);
  }

  /// `Following`
  String get followingStatus {
    return Intl.message(
      'Following',
      name: 'followingStatus',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get videos {
    return Intl.message('Videos', name: 'videos', desc: '', args: []);
  }

  /// `Diamonds`
  String get diamondsProfile {
    return Intl.message(
      'Diamonds',
      name: 'diamondsProfile',
      desc: '',
      args: [],
    );
  }

  /// `My Videos`
  String get myVideos {
    return Intl.message('My Videos', name: 'myVideos', desc: '', args: []);
  }

  /// `Videos of`
  String get videosOf {
    return Intl.message('Videos of', name: 'videosOf', desc: '', args: []);
  }

  /// `Badge Marketplace`
  String get badgeMarketplace {
    return Intl.message(
      'Badge Marketplace',
      name: 'badgeMarketplace',
      desc: '',
      args: [],
    );
  }

  /// `Refer Friends`
  String get referFriends {
    return Intl.message(
      'Refer Friends',
      name: 'referFriends',
      desc: '',
      args: [],
    );
  }

  /// `Earn 100 diamonds for every friend who joins Dadadu with your code!`
  String get referralDescription {
    return Intl.message(
      'Earn 100 diamonds for every friend who joins Dadadu with your code!',
      name: 'referralDescription',
      desc: '',
      args: [],
    );
  }

  /// `Copy Link`
  String get copyLink {
    return Intl.message('Copy Link', name: 'copyLink', desc: '', args: []);
  }

  /// `Share`
  String get share {
    return Intl.message('Share', name: 'share', desc: '', args: []);
  }

  /// `Change Username`
  String get changeUsername {
    return Intl.message(
      'Change Username',
      name: 'changeUsername',
      desc: '',
      args: [],
    );
  }

  /// `New username`
  String get newUsernameHint {
    return Intl.message(
      'New username',
      name: 'newUsernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Referral link copied! 📋`
  String get referralLinkCopied {
    return Intl.message(
      'Referral link copied! 📋',
      name: 'referralLinkCopied',
      desc: '',
      args: [],
    );
  }

  /// `🎬 Check out {username}’s profile on Dadadu!\nAn app for authentic short videos without likes or views.\n{profileUrl}\n\n#Dadadu #Profile`
  String shareProfileText(Object username, Object profileUrl) {
    return Intl.message(
      '🎬 Check out $username’s profile on Dadadu!\nAn app for authentic short videos without likes or views.\n$profileUrl\n\n#Dadadu #Profile',
      name: 'shareProfileText',
      desc: '',
      args: [username, profileUrl],
    );
  }

  /// `{username}’s Dadadu Profile`
  String shareProfileSubject(Object username) {
    return Intl.message(
      '$username’s Dadadu Profile',
      name: 'shareProfileSubject',
      desc: '',
      args: [username],
    );
  }

  /// `Error while sharing: {error}`
  String shareProfileError(Object error) {
    return Intl.message(
      'Error while sharing: $error',
      name: 'shareProfileError',
      desc: '',
      args: [error],
    );
  }

  /// `🎬 Join me on Dadadu! A short video app with no likes, just realness. Use my referral link to earn 100 💎: {referralLink}\n\n#Dadadu #Authentic #NoViews`
  String shareReferralText(Object referralLink) {
    return Intl.message(
      '🎬 Join me on Dadadu! A short video app with no likes, just realness. Use my referral link to earn 100 💎: $referralLink\n\n#Dadadu #Authentic #NoViews',
      name: 'shareReferralText',
      desc: '',
      args: [referralLink],
    );
  }

  /// `Join me on Dadadu!`
  String get shareReferralSubject {
    return Intl.message(
      'Join me on Dadadu!',
      name: 'shareReferralSubject',
      desc: '',
      args: [],
    );
  }

  /// `Listing removed`
  String get listingRemoved {
    return Intl.message(
      'Listing removed',
      name: 'listingRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorRemovingListing(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'errorRemovingListing',
      desc: '',
      args: [error],
    );
  }

  /// `You don't have enough diamonds!`
  String get notEnoughDiamonds {
    return Intl.message(
      'You don\'t have enough diamonds!',
      name: 'notEnoughDiamonds',
      desc: '',
      args: [],
    );
  }

  /// `Badge purchased successfully!`
  String get badgePurchased {
    return Intl.message(
      'Badge purchased successfully!',
      name: 'badgePurchased',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String badgePurchaseError(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'badgePurchaseError',
      desc: '',
      args: [error],
    );
  }

  /// `Badge listed successfully!`
  String get badgeListed {
    return Intl.message(
      'Badge listed successfully!',
      name: 'badgeListed',
      desc: '',
      args: [],
    );
  }

  /// `Error: {error}`
  String badgeListingError(Object error) {
    return Intl.message(
      'Error: $error',
      name: 'badgeListingError',
      desc: '',
      args: [error],
    );
  }

  /// `Sell your badge`
  String get sellBadgeTitle {
    return Intl.message(
      'Sell your badge',
      name: 'sellBadgeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Price in diamonds`
  String get priceLabel {
    return Intl.message(
      'Price in diamonds',
      name: 'priceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Suggested price: {price} 💎`
  String priceHint(Object price) {
    return Intl.message(
      'Suggested price: $price 💎',
      name: 'priceHint',
      desc: '',
      args: [price],
    );
  }

  /// `Description (optional)`
  String get descriptionLabel {
    return Intl.message(
      'Description (optional)',
      name: 'descriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buy {
    return Intl.message('Buy', name: 'buy', desc: '', args: []);
  }

  /// `Sell`
  String get sell {
    return Intl.message('Sell', name: 'sell', desc: '', args: []);
  }

  /// `Sell my current badge`
  String get sellCurrentBadgeTitle {
    return Intl.message(
      'Sell my current badge',
      name: 'sellCurrentBadgeTitle',
      desc: '',
      args: [],
    );
  }

  /// `List for sale`
  String get sellButton {
    return Intl.message(
      'List for sale',
      name: 'sellButton',
      desc: '',
      args: [],
    );
  }

  /// `You can only sell your own badges`
  String get ownBadgeSellError {
    return Intl.message(
      'You can only sell your own badges',
      name: 'ownBadgeSellError',
      desc: '',
      args: [],
    );
  }

  /// `My badges for sale`
  String get myBadgesForSale {
    return Intl.message(
      'My badges for sale',
      name: 'myBadgesForSale',
      desc: '',
      args: [],
    );
  }

  /// `No badges for sale`
  String get noBadgesForSale {
    return Intl.message(
      'No badges for sale',
      name: 'noBadgesForSale',
      desc: '',
      args: [],
    );
  }

  /// `Buy {diamonds} 💎`
  String buyForDiamonds(Object diamonds) {
    return Intl.message(
      'Buy $diamonds 💎',
      name: 'buyForDiamonds',
      desc: '',
      args: [diamonds],
    );
  }

  /// `Your badge`
  String get yourBadge {
    return Intl.message('Your badge', name: 'yourBadge', desc: '', args: []);
  }

  /// `🏆 DADADU BADGE SYSTEM`
  String get badgeSystemTitle {
    return Intl.message(
      '🏆 DADADU BADGE SYSTEM',
      name: 'badgeSystemTitle',
      desc: '',
      args: [],
    );
  }

  /// `LEAF (0–9,999 diamonds)`
  String get badgeLeafTitle {
    return Intl.message(
      'LEAF (0–9,999 diamonds)',
      name: 'badgeLeafTitle',
      desc: '',
      args: [],
    );
  }

  /// `Starting level for new users`
  String get badgeLeafDesc {
    return Intl.message(
      'Starting level for new users',
      name: 'badgeLeafDesc',
      desc: '',
      args: [],
    );
  }

  /// `THREELEAF (10K–999K)`
  String get badgeThreeleafTitle {
    return Intl.message(
      'THREELEAF (10K–999K)',
      name: 'badgeThreeleafTitle',
      desc: '',
      args: [],
    );
  }

  /// `Active community member`
  String get badgeThreeleafDesc {
    return Intl.message(
      'Active community member',
      name: 'badgeThreeleafDesc',
      desc: '',
      args: [],
    );
  }

  /// `FIVELEAF (1M–9.9M)`
  String get badgeFiveleafTitle {
    return Intl.message(
      'FIVELEAF (1M–9.9M)',
      name: 'badgeFiveleafTitle',
      desc: '',
      args: [],
    );
  }

  /// `Popular creator status`
  String get badgeFiveleafDesc {
    return Intl.message(
      'Popular creator status',
      name: 'badgeFiveleafDesc',
      desc: '',
      args: [],
    );
  }

  /// `DADALORD (10M+)`
  String get badgeDadalordTitle {
    return Intl.message(
      'DADALORD (10M+)',
      name: 'badgeDadalordTitle',
      desc: '',
      args: [],
    );
  }

  /// `Elite status worth \$10,000+ with +2% per million diamonds`
  String get badgeDadalordDesc {
    return Intl.message(
      'Elite status worth \\\$10,000+ with +2% per million diamonds',
      name: 'badgeDadalordDesc',
      desc: '',
      args: [],
    );
  }

  /// `📈 Higher badges = more prestige + marketplace value`
  String get badgeNote {
    return Intl.message(
      '📈 Higher badges = more prestige + marketplace value',
      name: 'badgeNote',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get gotIt {
    return Intl.message('Got it', name: 'gotIt', desc: '', args: []);
  }

  /// `✅ Profile photo removed`
  String get profilePhotoRemoved {
    return Intl.message(
      '✅ Profile photo removed',
      name: 'profilePhotoRemoved',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error while removing profile photo`
  String get profilePhotoRemoveError {
    return Intl.message(
      '❌ Error while removing profile photo',
      name: 'profilePhotoRemoveError',
      desc: '',
      args: [],
    );
  }

  /// `✅ Profile photo updated`
  String get profilePhotoUpdated {
    return Intl.message(
      '✅ Profile photo updated',
      name: 'profilePhotoUpdated',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error uploading profile photo`
  String get profilePhotoUpdateError {
    return Intl.message(
      '❌ Error uploading profile photo',
      name: 'profilePhotoUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message('Settings', name: 'settingsTitle', desc: '', args: []);
  }

  /// `User`
  String get userUnknown {
    return Intl.message('User', name: 'userUnknown', desc: '', args: []);
  }

  /// `Profile`
  String get profileSection {
    return Intl.message('Profile', name: 'profileSection', desc: '', args: []);
  }

  /// `Configure Discover`
  String get setupDiscover {
    return Intl.message(
      'Configure Discover',
      name: 'setupDiscover',
      desc: '',
      args: [],
    );
  }

  /// `Intent: {intent}`
  String intentWith(Object intent) {
    return Intl.message(
      'Intent: $intent',
      name: 'intentWith',
      desc: '',
      args: [intent],
    );
  }

  /// `Not configured`
  String get notConfigured {
    return Intl.message(
      'Not configured',
      name: 'notConfigured',
      desc: '',
      args: [],
    );
  }

  /// `Not defined`
  String get notDefined {
    return Intl.message('Not defined', name: 'notDefined', desc: '', args: []);
  }

  /// `Profile Photo`
  String get profilePhoto {
    return Intl.message(
      'Profile Photo',
      name: 'profilePhoto',
      desc: '',
      args: [],
    );
  }

  /// `Photo set`
  String get photoSet {
    return Intl.message('Photo set', name: 'photoSet', desc: '', args: []);
  }

  /// `No photo`
  String get noPhoto {
    return Intl.message('No photo', name: 'noPhoto', desc: '', args: []);
  }

  /// `General`
  String get generalSection {
    return Intl.message('General', name: 'generalSection', desc: '', args: []);
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message('Dark mode', name: 'darkMode', desc: '', args: []);
  }

  /// `Light mode`
  String get lightMode {
    return Intl.message('Light mode', name: 'lightMode', desc: '', args: []);
  }

  /// `Security`
  String get securitySection {
    return Intl.message(
      'Security',
      name: 'securitySection',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Send password reset email`
  String get sendResetEmail {
    return Intl.message(
      'Send password reset email',
      name: 'sendResetEmail',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message('Log Out', name: 'logout', desc: '', args: []);
  }

  /// `Sign out of the app`
  String get logoutDescription {
    return Intl.message(
      'Sign out of the app',
      name: 'logoutDescription',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get logoutConfirm {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `🎯 Discover configuration updated`
  String get discoverConfigUpdated {
    return Intl.message(
      '🎯 Discover configuration updated',
      name: 'discoverConfigUpdated',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error while saving configuration`
  String get discoverConfigError {
    return Intl.message(
      '❌ Error while saving configuration',
      name: 'discoverConfigError',
      desc: '',
      args: [],
    );
  }

  /// `Discover Configuration`
  String get discoverConfigTitle {
    return Intl.message(
      'Discover Configuration',
      name: 'discoverConfigTitle',
      desc: '',
      args: [],
    );
  }

  /// `Select your intent`
  String get selectIntent {
    return Intl.message(
      'Select your intent',
      name: 'selectIntent',
      desc: '',
      args: [],
    );
  }

  /// `Social network`
  String get socialNetworkLabel {
    return Intl.message(
      'Social network',
      name: 'socialNetworkLabel',
      desc: '',
      args: [],
    );
  }

  /// `Your ID`
  String get identifierHint {
    return Intl.message('Your ID', name: 'identifierHint', desc: '', args: []);
  }

  /// `Save`
  String get saveButton {
    return Intl.message('Save', name: 'saveButton', desc: '', args: []);
  }

  /// `love`
  String get intentLove {
    return Intl.message('love', name: 'intentLove', desc: '', args: []);
  }

  /// `business`
  String get intentBusiness {
    return Intl.message('business', name: 'intentBusiness', desc: '', args: []);
  }

  /// `entertainment`
  String get intentEntertainment {
    return Intl.message(
      'entertainment',
      name: 'intentEntertainment',
      desc: '',
      args: [],
    );
  }

  /// `📧 Reset email sent to {email}`
  String resetEmailSent(Object email) {
    return Intl.message(
      '📧 Reset email sent to $email',
      name: 'resetEmailSent',
      desc: '',
      args: [email],
    );
  }

  /// `❌ Error sending the reset email`
  String get resetEmailError {
    return Intl.message(
      '❌ Error sending the reset email',
      name: 'resetEmailError',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error while selecting the image`
  String get imageSelectionError {
    return Intl.message(
      '❌ Error while selecting the image',
      name: 'imageSelectionError',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `✅ Username updated`
  String get usernameUpdated {
    return Intl.message(
      '✅ Username updated',
      name: 'usernameUpdated',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error updating username`
  String get usernameUpdateError {
    return Intl.message(
      '❌ Error updating username',
      name: 'usernameUpdateError',
      desc: '',
      args: [],
    );
  }

  /// `New username`
  String get changeUsernameTitle {
    return Intl.message(
      'New username',
      name: 'changeUsernameTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter your new name`
  String get changeUsernameHint {
    return Intl.message(
      'Enter your new name',
      name: 'changeUsernameHint',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Trim Your Video`
  String get trimTitle {
    return Intl.message(
      'Trim Your Video',
      name: 'trimTitle',
      desc: '',
      args: [],
    );
  }

  /// `Trim and Continue`
  String get trimContinue {
    return Intl.message(
      'Trim and Continue',
      name: 'trimContinue',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `🎬 Check out this video on Dadadu!\n"{caption}"\nBy @{username}\n\n📱 Authentic video app without likes or views\n#Dadadu #Authentic #Local`
  String shareBaseText(Object caption, Object username) {
    return Intl.message(
      '🎬 Check out this video on Dadadu!\n"$caption"\nBy @$username\n\n📱 Authentic video app without likes or views\n#Dadadu #Authentic #Local',
      name: 'shareBaseText',
      desc: '',
      args: [caption, username],
    );
  }

  /// `💎 Download Dadadu and earn diamonds!`
  String get shareWhatsAppSuffix {
    return Intl.message(
      '💎 Download Dadadu and earn diamonds!',
      name: 'shareWhatsAppSuffix',
      desc: '',
      args: [],
    );
  }

  /// `📲 #DadaduApp #NoLikes #RealContent`
  String get shareInstagramSuffix {
    return Intl.message(
      '📲 #DadaduApp #NoLikes #RealContent',
      name: 'shareInstagramSuffix',
      desc: '',
      args: [],
    );
  }

  /// `🌟 Join the authentic content revolution!`
  String get shareFacebookSuffix {
    return Intl.message(
      '🌟 Join the authentic content revolution!',
      name: 'shareFacebookSuffix',
      desc: '',
      args: [],
    );
  }

  /// `👻 No more algorithm, more real!`
  String get shareSnapchatSuffix {
    return Intl.message(
      '👻 No more algorithm, more real!',
      name: 'shareSnapchatSuffix',
      desc: '',
      args: [],
    );
  }

  /// `❌ Storage permission required`
  String get permissionRequired {
    return Intl.message(
      '❌ Storage permission required',
      name: 'permissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `📥 Downloading...`
  String get downloading {
    return Intl.message(
      '📥 Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `✅ Saved to Downloads!`
  String get videoSaved {
    return Intl.message(
      '✅ Saved to Downloads!',
      name: 'videoSaved',
      desc: '',
      args: [],
    );
  }

  /// `❌ Error saving video: {error}`
  String errorSavingVideo(Object error) {
    return Intl.message(
      '❌ Error saving video: $error',
      name: 'errorSavingVideo',
      desc: '',
      args: [error],
    );
  }

  /// `📤 Share this video`
  String get shareVideo {
    return Intl.message(
      '📤 Share this video',
      name: 'shareVideo',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Other`
  String get other {
    return Intl.message('Other', name: 'other', desc: '', args: []);
  }

  /// `❌ Error sharing: {error}`
  String shareError(Object error) {
    return Intl.message(
      '❌ Error sharing: $error',
      name: 'shareError',
      desc: '',
      args: [error],
    );
  }

  /// `Replying to {username}`
  String replyingTo(Object username) {
    return Intl.message(
      'Replying to $username',
      name: 'replyingTo',
      desc: '',
      args: [username],
    );
  }

  /// `Reply to comment...`
  String get replyToComment {
    return Intl.message(
      'Reply to comment...',
      name: 'replyToComment',
      desc: '',
      args: [],
    );
  }

  /// `Add a comment...`
  String get addComment {
    return Intl.message(
      'Add a comment...',
      name: 'addComment',
      desc: '',
      args: [],
    );
  }

  /// `CREATOR`
  String get creator {
    return Intl.message('CREATOR', name: 'creator', desc: '', args: []);
  }

  /// `Reply`
  String get reply {
    return Intl.message('Reply', name: 'reply', desc: '', args: []);
  }

  /// `{count} {count, plural, one{reply} other{replies}}`
  String repliesCount(num count) {
    return Intl.message(
      '$count ${Intl.plural(count, one: 'reply', other: 'replies')}',
      name: 'repliesCount',
      desc: '',
      args: [count],
    );
  }

  /// `Be the first to comment!`
  String get noCommentsTitle {
    return Intl.message(
      'Be the first to comment!',
      name: 'noCommentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Share your thoughts about this video`
  String get noCommentsSubtitle {
    return Intl.message(
      'Share your thoughts about this video',
      name: 'noCommentsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `🕒 Recent`
  String get sortRecent {
    return Intl.message('🕒 Recent', name: 'sortRecent', desc: '', args: []);
  }

  /// `🔥 Popular`
  String get sortPopular {
    return Intl.message('🔥 Popular', name: 'sortPopular', desc: '', args: []);
  }

  /// `📈 Trending`
  String get sortTrending {
    return Intl.message(
      '📈 Trending',
      name: 'sortTrending',
      desc: '',
      args: [],
    );
  }

  /// `💬 Comments`
  String get commentsTitle {
    return Intl.message(
      '💬 Comments',
      name: 'commentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `{count} comments`
  String commentsCount(Object count) {
    return Intl.message(
      '$count comments',
      name: 'commentsCount',
      desc: '',
      args: [count],
    );
  }

  /// `You must be logged in to comment`
  String get mustBeLoggedIn {
    return Intl.message(
      'You must be logged in to comment',
      name: 'mustBeLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `💬 Comment posted!`
  String get commentPosted {
    return Intl.message(
      '💬 Comment posted!',
      name: 'commentPosted',
      desc: '',
      args: [],
    );
  }

  /// `Error sending comment`
  String get commentError {
    return Intl.message(
      'Error sending comment',
      name: 'commentError',
      desc: '',
      args: [],
    );
  }

  /// `💬 New comment`
  String get newCommentNotification {
    return Intl.message(
      '💬 New comment',
      name: 'newCommentNotification',
      desc: '',
      args: [],
    );
  }

  /// `{username} commented on your video`
  String userCommented(Object username) {
    return Intl.message(
      '$username commented on your video',
      name: 'userCommented',
      desc: '',
      args: [username],
    );
  }

  /// `Create Video`
  String get createVideoTitle {
    return Intl.message(
      'Create Video',
      name: 'createVideoTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create your Dadadu video`
  String get createDadaduVideo {
    return Intl.message(
      'Create your Dadadu video',
      name: 'createDadaduVideo',
      desc: '',
      args: [],
    );
  }

  /// `Maximum 20 seconds`
  String get maximum20Seconds {
    return Intl.message(
      'Maximum 20 seconds',
      name: 'maximum20Seconds',
      desc: '',
      args: [],
    );
  }

  /// `Describe your video...\nWhat do you want to share?`
  String get captionHint {
    return Intl.message(
      'Describe your video...\nWhat do you want to share?',
      name: 'captionHint',
      desc: '',
      args: [],
    );
  }

  /// `PUBLISH VIDEO`
  String get publishVideoButton {
    return Intl.message(
      'PUBLISH VIDEO',
      name: 'publishVideoButton',
      desc: '',
      args: [],
    );
  }

  /// `Add a caption to publish your video`
  String get infoAddCaption {
    return Intl.message(
      'Add a caption to publish your video',
      name: 'infoAddCaption',
      desc: '',
      args: [],
    );
  }

  /// `Select or record a video to get started`
  String get infoSelectOrRecord {
    return Intl.message(
      'Select or record a video to get started',
      name: 'infoSelectOrRecord',
      desc: '',
      args: [],
    );
  }

  /// `Video Intent`
  String get videoIntent {
    return Intl.message(
      'Video Intent',
      name: 'videoIntent',
      desc: '',
      args: [],
    );
  }

  /// `Fun`
  String get intentFun {
    return Intl.message('Fun', name: 'intentFun', desc: '', args: []);
  }

  /// `Serious`
  String get intentSerious {
    return Intl.message('Serious', name: 'intentSerious', desc: '', args: []);
  }

  /// `Informative`
  String get intentInformative {
    return Intl.message(
      'Informative',
      name: 'intentInformative',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Initializing camera...`
  String get initializingCamera {
    return Intl.message(
      'Initializing camera...',
      name: 'initializingCamera',
      desc: '',
      args: [],
    );
  }

  /// `No video selected`
  String get noVideoSelected {
    return Intl.message(
      'No video selected',
      name: 'noVideoSelected',
      desc: '',
      args: [],
    );
  }

  /// `Please add a caption`
  String get pleaseAddCaption {
    return Intl.message(
      'Please add a caption',
      name: 'pleaseAddCaption',
      desc: '',
      args: [],
    );
  }

  /// `User not logged in`
  String get userNotLoggedIn {
    return Intl.message(
      'User not logged in',
      name: 'userNotLoggedIn',
      desc: '',
      args: [],
    );
  }

  /// `User profile not found`
  String get userProfileNotFound {
    return Intl.message(
      'User profile not found',
      name: 'userProfileNotFound',
      desc: '',
      args: [],
    );
  }

  /// `🎉 Video published successfully!`
  String get videoPublishedSuccessfully {
    return Intl.message(
      '🎉 Video published successfully!',
      name: 'videoPublishedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Upload error`
  String get uploadError {
    return Intl.message(
      'Upload error',
      name: 'uploadError',
      desc: '',
      args: [],
    );
  }

  /// `Stop recording error: {error}`
  String stopRecordingError(Object error) {
    return Intl.message(
      'Stop recording error: $error',
      name: 'stopRecordingError',
      desc: '',
      args: [error],
    );
  }

  /// `Recording error: {error}`
  String recordingError(Object error) {
    return Intl.message(
      'Recording error: $error',
      name: 'recordingError',
      desc: '',
      args: [error],
    );
  }

  /// `Selection error: {error}`
  String selectionError(Object error) {
    return Intl.message(
      'Selection error: $error',
      name: 'selectionError',
      desc: '',
      args: [error],
    );
  }

  /// `Video loading error: {error}`
  String videoLoadingError(Object error) {
    return Intl.message(
      'Video loading error: $error',
      name: 'videoLoadingError',
      desc: '',
      args: [error],
    );

  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
