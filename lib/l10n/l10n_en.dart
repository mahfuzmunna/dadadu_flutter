// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get createYourDadaduID => 'Create your Dadadu ID 🚀';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get signUp => 'SIGN UP';

  @override
  String get creating => 'Creating...';

  @override
  String get welcomeBack => 'Welcome back 👽';

  @override
  String get login => 'LOGIN';

  @override
  String get loading => 'Loading...';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get invalidPhone =>
      'Please enter a valid phone number (with +country code)';

  @override
  String get genericError => 'An error occurred. Please try again.';

  @override
  String get welcomeToDadadu => 'Welcome to Dadadu';

  @override
  String get welcomeSignUp => 'Sign Up';

  @override
  String get welcomeLogin => 'Log In';

  @override
  String get navNow => 'Now';

  @override
  String get navUpload => 'Upload';

  @override
  String get navProfile => 'Profile';

  @override
  String get feedPersonalizing => 'Personalizing your feed...';

  @override
  String get feedAnalyzingPreferences => 'Analyzing your preferences';

  @override
  String get noVideos => 'No videos available';

  @override
  String get followCreators => 'Follow creators to see their content';

  @override
  String get refresh => 'Refresh';

  @override
  String get nowLabel => 'Now';

  @override
  String get discover => 'Discover';

  @override
  String get noMatchesFoundNearby => 'No matches found nearby';

  @override
  String get tryChangingIntentOrLater =>
      'Try changing your intent or check back later';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get scanningForConnections => 'Scanning for connections...';

  @override
  String lookingForIntentNearby(Object intent) {
    return 'Looking for $intent nearby';
  }

  @override
  String get cancelSearch => 'Cancel Search';

  @override
  String get whatsYourVibe => 'What\'s your vibe today?';

  @override
  String get locationPermissionNeeded =>
      '📍 Location access needed for matching nearby users';

  @override
  String get locationPermissionRequired =>
      'Location permission required for matching';

  @override
  String get interestSentWaiting => 'Interest sent! Waiting for response...';

  @override
  String get mutualMatchTitle => '🎉 Mutual Match!';

  @override
  String get contactLabel => 'Contact for matches';

  @override
  String get noContactInfo => 'No contact info';

  @override
  String get greatButton => 'Great!';

  @override
  String get interestFailed => 'Failed to express interest';

  @override
  String get searchFailed => 'Search failed';

  @override
  String matchFound(Object emoji) {
    return '$emoji Match Found!';
  }

  @override
  String get perfectMatch => 'Perfect Match';

  @override
  String get greatMatch => 'Great Match';

  @override
  String get goodMatch => 'Good Match';

  @override
  String mood(Object emoji, Object mood) {
    return '$emoji $mood';
  }

  @override
  String away(Object distance) {
    return '${distance}m away';
  }

  @override
  String diamonds(Object count) {
    return '$count diamonds';
  }

  @override
  String get skip => 'Skip';

  @override
  String get interested => 'I\'m Interested';

  @override
  String get enterOtpMessage => 'Enter the OTP sent to your phone';

  @override
  String get otpHint => '6-digit code';

  @override
  String get verify => 'Verify';

  @override
  String get otpError => 'OTP incorrect. Please try again.';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get error => 'Error';

  @override
  String get cropFailed => 'Failed to crop image';

  @override
  String get ok => 'OK';

  @override
  String get noImageLoaded => 'No image loaded';

  @override
  String get loadingImage => 'Loading image...';

  @override
  String get imageReady => 'Image ready!';

  @override
  String get cropping => 'Cropping...';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get cropAndSave => 'Crop & Save';

  @override
  String get user => 'User';

  @override
  String get profile => 'Profile';

  @override
  String get moodProfile => 'Mood';

  @override
  String get howBadgesWork => 'How Badges Work';

  @override
  String get followers => 'Followers';

  @override
  String get following => 'Following';

  @override
  String get rank => 'Rank';

  @override
  String get noMatchHistory => 'No match history.';

  @override
  String get matchHistory => 'Match History';

  @override
  String get matchedWith => 'Matched with';

  @override
  String get unknown => 'Unknown';

  @override
  String get intent => 'Intent';

  @override
  String get follow => 'Follow';

  @override
  String get followingStatus => 'Following';

  @override
  String get videos => 'Videos';

  @override
  String get diamondsProfile => 'Diamonds';

  @override
  String get myVideos => 'My Videos';

  @override
  String get videosOf => 'Videos of';

  @override
  String get badgeMarketplace => 'Badge Marketplace';

  @override
  String get referFriends => 'Refer Friends';

  @override
  String get referralDescription =>
      'Earn 100 diamonds for every friend who joins Dadadu with your code!';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get share => 'Share';

  @override
  String get changeUsername => 'Change Username';

  @override
  String get newUsernameHint => 'New username';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get referralLinkCopied => 'Referral link copied! 📋';

  @override
  String shareProfileText(Object profileUrl, Object username) {
    return '🎬 Check out $username’s profile on Dadadu!\nAn app for authentic short videos without likes or views.\n$profileUrl\n\n#Dadadu #Profile';
  }

  @override
  String shareProfileSubject(Object username) {
    return '$username’s Dadadu Profile';
  }

  @override
  String shareProfileError(Object error) {
    return 'Error while sharing: $error';
  }

  @override
  String shareReferralText(Object referralLink) {
    return '🎬 Join me on Dadadu! A short video app with no likes, just realness. Use my referral link to earn 100 💎: $referralLink\n\n#Dadadu #Authentic #NoViews';
  }

  @override
  String get shareReferralSubject => 'Join me on Dadadu!';

  @override
  String get listingRemoved => 'Listing removed';

  @override
  String errorRemovingListing(Object error) {
    return 'Error: $error';
  }

  @override
  String get notEnoughDiamonds => 'You don\'t have enough diamonds!';

  @override
  String get badgePurchased => 'Badge purchased successfully!';

  @override
  String badgePurchaseError(Object error) {
    return 'Error: $error';
  }

  @override
  String get badgeListed => 'Badge listed successfully!';

  @override
  String badgeListingError(Object error) {
    return 'Error: $error';
  }

  @override
  String get sellBadgeTitle => 'Sell your badge';

  @override
  String get priceLabel => 'Price in diamonds';

  @override
  String priceHint(Object price) {
    return 'Suggested price: $price 💎';
  }

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get buy => 'Buy';

  @override
  String get sell => 'Sell';

  @override
  String get sellCurrentBadgeTitle => 'Sell my current badge';

  @override
  String get sellButton => 'List for sale';

  @override
  String get ownBadgeSellError => 'You can only sell your own badges';

  @override
  String get myBadgesForSale => 'My badges for sale';

  @override
  String get noBadgesForSale => 'No badges for sale';

  @override
  String buyForDiamonds(Object diamonds) {
    return 'Buy $diamonds 💎';
  }

  @override
  String get yourBadge => 'Your badge';

  @override
  String get badgeSystemTitle => '🏆 DADADU BADGE SYSTEM';

  @override
  String get badgeLeafTitle => 'LEAF (0–9,999 diamonds)';

  @override
  String get badgeLeafDesc => 'Starting level for new users';

  @override
  String get badgeThreeleafTitle => 'THREELEAF (10K–999K)';

  @override
  String get badgeThreeleafDesc => 'Active community member';

  @override
  String get badgeFiveleafTitle => 'FIVELEAF (1M–9.9M)';

  @override
  String get badgeFiveleafDesc => 'Popular creator status';

  @override
  String get badgeDadalordTitle => 'DADALORD (10M+)';

  @override
  String get badgeDadalordDesc =>
      'Elite status worth \\\$10,000+ with +2% per million diamonds';

  @override
  String get badgeNote =>
      '📈 Higher badges = more prestige + marketplace value';

  @override
  String get gotIt => 'Got it';

  @override
  String get profilePhotoRemoved => '✅ Profile photo removed';

  @override
  String get profilePhotoRemoveError => '❌ Error while removing profile photo';

  @override
  String get profilePhotoUpdated => '✅ Profile photo updated';

  @override
  String get profilePhotoUpdateError => '❌ Error uploading profile photo';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get userUnknown => 'User';

  @override
  String get profileSection => 'Profile';

  @override
  String get setupDiscover => 'Configure Discover';

  @override
  String intentWith(Object intent) {
    return 'Intent: $intent';
  }

  @override
  String get notConfigured => 'Not configured';

  @override
  String get notDefined => 'Not defined';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get photoSet => 'Photo set';

  @override
  String get noPhoto => 'No photo';

  @override
  String get generalSection => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get securitySection => 'Security';

  @override
  String get changePassword => 'Change Password';

  @override
  String get sendResetEmail => 'Send password reset email';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutDescription => 'Sign out of the app';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get discoverConfigUpdated => '🎯 Discover configuration updated';

  @override
  String get discoverConfigError => '❌ Error while saving configuration';

  @override
  String get discoverConfigTitle => 'Discover Configuration';

  @override
  String get selectIntent => 'Select your intent';

  @override
  String get socialNetworkLabel => 'Social network';

  @override
  String get identifierHint => 'Your ID';

  @override
  String get saveButton => 'Save';

  @override
  String get intentLove => 'love';

  @override
  String get intentBusiness => 'business';

  @override
  String get intentEntertainment => 'entertainment';

  @override
  String resetEmailSent(Object email) {
    return '📧 Reset email sent to $email';
  }

  @override
  String get resetEmailError => '❌ Error sending the reset email';

  @override
  String get imageSelectionError => '❌ Error while selecting the image';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get delete => 'Delete';

  @override
  String get usernameUpdated => '✅ Username updated';

  @override
  String get usernameUpdateError => '❌ Error updating username';

  @override
  String get changeUsernameTitle => 'New username';

  @override
  String get changeUsernameHint => 'Enter your new name';

  @override
  String get confirm => 'Confirm';

  @override
  String get trimTitle => 'Trim Your Video';

  @override
  String get trimContinue => 'Trim and Continue';

  @override
  String get language => 'Language';

  @override
  String shareBaseText(Object caption, Object username) {
    return '🎬 Check out this video on Dadadu!\n\"$caption\"\nBy @$username\n\n📱 Authentic video app without likes or views\n#Dadadu #Authentic #Local';
  }

  @override
  String get shareWhatsAppSuffix => '💎 Download Dadadu and earn diamonds!';

  @override
  String get shareInstagramSuffix => '📲 #DadaduApp #NoLikes #RealContent';

  @override
  String get shareFacebookSuffix => '🌟 Join the authentic content revolution!';

  @override
  String get shareSnapchatSuffix => '👻 No more algorithm, more real!';

  @override
  String get permissionRequired => '❌ Storage permission required';

  @override
  String get downloading => '📥 Downloading...';

  @override
  String get videoSaved => '✅ Saved to Downloads!';

  @override
  String errorSavingVideo(Object error) {
    return '❌ Error saving video: $error';
  }

  @override
  String get shareVideo => '📤 Share this video';

  @override
  String get download => 'Download';

  @override
  String get other => 'Other';

  @override
  String shareError(Object error) {
    return '❌ Error sharing: $error';
  }

  @override
  String replyingTo(Object username) {
    return 'Replying to $username';
  }

  @override
  String get replyToComment => 'Reply to comment...';

  @override
  String get addComment => 'Add a comment...';

  @override
  String get creator => 'CREATOR';

  @override
  String get reply => 'Reply';

  @override
  String repliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'replies',
      one: 'reply',
    );
    return '$count $_temp0';
  }

  @override
  String get noCommentsTitle => 'Be the first to comment!';

  @override
  String get noCommentsSubtitle => 'Share your thoughts about this video';

  @override
  String get sortRecent => '🕒 Recent';

  @override
  String get sortPopular => '🔥 Popular';

  @override
  String get sortTrending => '📈 Trending';

  @override
  String get commentsTitle => '💬 Comments';

  @override
  String commentsCount(Object count) {
    return '$count comments';
  }

  @override
  String get mustBeLoggedIn => 'You must be logged in to comment';

  @override
  String get commentPosted => '💬 Comment posted!';

  @override
  String get commentError => 'Error sending comment';

  @override
  String get newCommentNotification => '💬 New comment';

  @override
  String userCommented(Object username) {
    return '$username commented on your video';
  }

  @override
  String get createVideoTitle => 'Create Video';

  @override
  String get createDadaduVideo => 'Create your Dadadu video';

  @override
  String get maximum20Seconds => 'Maximum 20 seconds';

  @override
  String get captionHint =>
      'Describe your video...\nWhat do you want to share?';

  @override
  String get publishVideoButton => 'PUBLISH VIDEO';

  @override
  String get infoAddCaption => 'Add a caption to publish your video';

  @override
  String get infoSelectOrRecord => 'Select or record a video to get started';

  @override
  String get videoIntent => 'Video Intent';

  @override
  String get intentFun => 'Fun';

  @override
  String get intentSerious => 'Serious';

  @override
  String get intentInformative => 'Informative';

  @override
  String get close => 'Close';

  @override
  String get initializingCamera => 'Initializing camera...';

  @override
  String get noVideoSelected => 'No video selected';

  @override
  String get pleaseAddCaption => 'Please add a caption';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get userProfileNotFound => 'User profile not found';

  @override
  String get videoPublishedSuccessfully => '🎉 Video published successfully!';

  @override
  String get uploadError => 'Upload error';

  @override
  String stopRecordingError(Object error) {
    return 'Stop recording error: $error';
  }

  @override
  String recordingError(Object error) {
    return 'Recording error: $error';
  }

  @override
  String selectionError(Object error) {
    return 'Selection error: $error';
  }

  @override
  String videoLoadingError(Object error) {
    return 'Video loading error: $error';
  }
}
