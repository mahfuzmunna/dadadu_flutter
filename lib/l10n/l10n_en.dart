// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get general => 'General';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get language => 'Language';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get support => 'Support';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get aboutDadadu => 'About Dadadu';

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOut => 'Confirm Sign Out';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get close => 'Close';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get login => 'Login';

  @override
  String loginFailed(Object message) {
    return 'Login failed: $message';
  }

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'your@example.com';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get or => 'OR';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpSuccess => 'Success! Please check your email to verify.';

  @override
  String signUpFailed(Object message) {
    return 'Sign up failed: $message';
  }

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get username => 'Username';

  @override
  String get pleaseEnterAUsername => 'Please enter a username';

  @override
  String get pleaseEnterAnEmail => 'Please enter an email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get continueButton => 'Continue';

  @override
  String referralId(Object referralId) {
    return 'Referral ID: $referralId';
  }

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get setYourProfilePhoto => 'Set Your Profile Photo';

  @override
  String get pleaseSelectAndEditImage =>
      'Please select and edit an image first.';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get greatFirstImpression => 'Make a great first impression!';

  @override
  String get uploadAndContinue => 'Upload and Continue';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String passwordResetEmailSent(Object email) {
    return 'Password reset email sent to $email. Check your inbox.';
  }

  @override
  String passwordResetFailed(Object message) {
    return 'Password reset failed: $message';
  }

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get notifications => 'Notifications';

  @override
  String get now => 'NOW';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get noPostsFound => 'No posts found.';

  @override
  String get recent => 'Recent';

  @override
  String get popular => 'Popular';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get mustBeLoggedInToComment => 'You must be logged in to comment.';

  @override
  String get commentSubmitted => 'Comment submitted!';

  @override
  String get addAComment => 'Add a comment...';

  @override
  String get mustBeLoggedInToLike => 'You must be logged in to like.';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get translating => 'Translating...';

  @override
  String get translate => 'Translate';

  @override
  String get sent => 'Sent';

  @override
  String get storagePermissionRequired =>
      'Storage permission is required to save videos.';

  @override
  String get videoSavedToGallery => 'Video saved to gallery!';

  @override
  String get failedToSaveVideo => 'Failed to save video.';

  @override
  String get errorSavingVideo => 'An error occurred while saving the video.';

  @override
  String get loading => 'loading...';

  @override
  String originalSoundBy(Object username) {
    return 'Original Sound - $username';
  }

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get share => 'Share';

  @override
  String shareVideoMessage(Object postId) {
    return 'Check out this video! https://dadadu.app/$postId';
  }

  @override
  String get cannotGiveDiamondToSelf =>
      'You can\'t give a diamond to yourself.';

  @override
  String get newPost => 'New Post';

  @override
  String get postPublishedSuccess => 'Post published successfully!';

  @override
  String uploadFailed(Object message) {
    return 'Upload failed: $message';
  }

  @override
  String get chooseACover => 'Choose a cover';

  @override
  String get selectAnIntent => 'Select an Intent';

  @override
  String get processing => 'Processing...';

  @override
  String publishing(Object progress) {
    return 'Publishing... $progress%';
  }

  @override
  String get publish => 'Publish';

  @override
  String get addACaption => 'Add a caption...';

  @override
  String get couldNotGenerateThumbnails => 'Could not generate thumbnails.';

  @override
  String get love => 'Love';

  @override
  String get business => 'Business';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get pleaseSelectAThumbnail => 'Please select a thumbnail.';

  @override
  String get couldNotProcessVideo =>
      'Could not process video. Please try again.';

  @override
  String errorPublishingPost(Object error) {
    return 'Error publishing post: $error';
  }

  @override
  String get editProfile => 'Edit Profile';
}
