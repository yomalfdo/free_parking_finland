// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Free Parking Finland';

  @override
  String get mapPlaceholderTitle => 'Map view';

  @override
  String get mapPlaceholderSubtitle => 'Real map coming soon';

  @override
  String get locationPermissionDialogTitle => 'Location access needed';

  @override
  String get locationPermissionDialogBody =>
      'We use your location to show free parking spots near you and let you report the ones you find. This app won\'t work without it.';

  @override
  String get locationPermissionContinue => 'Continue';

  @override
  String get locationPermissionDenied =>
      'Location permission is required to use this app.';

  @override
  String get locationPermissionRetry => 'Try again';

  @override
  String get locationPermissionOpenSettings => 'Open settings';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Location access is turned off for this app. Please enable it in your phone\'s settings.';

  @override
  String get locationServicesDisabled =>
      'Location services are turned off. Please turn them on in your phone\'s settings.';

  @override
  String get accountTooltip => 'Account';

  @override
  String get accountScreenTitle => 'Account';

  @override
  String get guestStatusLabel =>
      'You\'re using a guest account. Create an account to keep your data if you switch phones.';

  @override
  String signedInAsLabel(String email) {
    return 'Signed in as $email';
  }

  @override
  String get signUpTitle => 'Create an account';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get signInButton => 'Sign in';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get switchToSignUp => 'New here? Create an account';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get authGenericError => 'Something went wrong. Please try again.';

  @override
  String get authEmailAlreadyInUse =>
      'That email is already registered. Try signing in instead.';

  @override
  String get authWeakPassword =>
      'Choose a stronger password (at least 6 characters).';

  @override
  String get authInvalidEmail =>
      'That doesn\'t look like a valid email address.';

  @override
  String get authWrongCredentials => 'Incorrect email or password.';

  @override
  String get addSpotTooltip => 'Add spot';

  @override
  String get captureScreenTitle => 'Photograph the sign';

  @override
  String get captureInstructions =>
      'Frame the parking sign clearly, then tap to capture.';

  @override
  String get captureButtonLabel => 'Capture';

  @override
  String get cameraPermissionDenied =>
      'Camera access is needed to report a spot.';

  @override
  String get cameraPermissionOpenSettings => 'Open settings';

  @override
  String get capturingLocation => 'Getting your location...';

  @override
  String get captureFailed => 'Couldn\'t take the photo. Please try again.';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get usePhoto => 'Use this photo';

  @override
  String get confirmScreenTitle => 'Confirm the rules';

  @override
  String get confirmInstructions =>
      'Here\'s what we read from the sign. Edit anything that\'s not right.';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get freeDaysLabel => 'Free days';

  @override
  String get freeHoursLabel => 'Free hours';

  @override
  String get allDayToggleLabel => 'Free all day';

  @override
  String get fromTimeLabel => 'From';

  @override
  String get toTimeLabel => 'To';

  @override
  String get maxDurationLabel => 'Max stay';

  @override
  String get noLimitLabel => 'No limit';

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get exceptionsLabel => 'Exceptions';

  @override
  String get exceptionsHint => 'e.g. residents exempt';

  @override
  String get confirmAndSubmitButton => 'Confirm and submit';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get spotSubmittedMessage =>
      'Spot reported. Thanks for helping others find free parking!';

  @override
  String get dayMonday => 'Mon';

  @override
  String get dayTuesday => 'Tue';

  @override
  String get dayWednesday => 'Wed';

  @override
  String get dayThursday => 'Thu';

  @override
  String get dayFriday => 'Fri';

  @override
  String get daySaturday => 'Sat';

  @override
  String get daySunday => 'Sun';

  @override
  String get toggleToListView => 'Switch to list view';

  @override
  String get toggleToMapView => 'Switch to map view';

  @override
  String get noSpotsNearbyMessage =>
      'No free parking spots reported nearby yet.';

  @override
  String get spotDetailTitle => 'Parking spot';

  @override
  String get justNowLabel => 'Just now';

  @override
  String reportedMinutesAgo(int minutes) {
    return 'Reported $minutes min ago';
  }

  @override
  String reportedHoursAgo(int hours) {
    return 'Reported $hours h ago';
  }

  @override
  String reportedDaysAgo(int days) {
    return 'Reported $days d ago';
  }

  @override
  String get navigateButton => 'Navigate';

  @override
  String get chooseNavigationAppTitle => 'Choose navigation app';

  @override
  String get googleMapsOption => 'Google Maps';

  @override
  String get appleMapsOption => 'Apple Maps';

  @override
  String get statusFreeNowLabel => 'Free right now';

  @override
  String get statusReportedFullLabel => 'Reported full';

  @override
  String get statusNotFreeNowLabel => 'Not currently free';

  @override
  String distanceMetersValue(int value) {
    return '$value m';
  }

  @override
  String distanceKilometersValue(String value) {
    return '$value km';
  }

  @override
  String get registerToRemoveAdsMessage =>
      'Tired of ads? Create a free account to remove them.';

  @override
  String get createAccountAction => 'Create account';

  @override
  String get reportButton => 'Report incorrect info';

  @override
  String get reportScreenTitle => 'Report incorrect rules';

  @override
  String get reportInstructions =>
      'Photograph the sign again so we can double-check the rules.';

  @override
  String get reportConfirmInstructions =>
      'Here\'s what we read from the sign. Edit anything that\'s not right, then submit your correction.';

  @override
  String get submitCorrectionButton => 'Submit correction';

  @override
  String get correctionSubmittedMessage =>
      'Thanks! Once enough people agree, we\'ll update this spot\'s info.';
}
