import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('fi'),
    Locale('sv'),
  ];

  /// The application name, shown on the home screen and app switcher.
  ///
  /// In en, this message translates to:
  /// **'Free Parking Finland'**
  String get appTitle;

  /// Heading shown over the placeholder box that will later hold the real map.
  ///
  /// In en, this message translates to:
  /// **'Map view'**
  String get mapPlaceholderTitle;

  /// Subtext under the map placeholder heading.
  ///
  /// In en, this message translates to:
  /// **'Real map coming soon'**
  String get mapPlaceholderSubtitle;

  /// Title of the dialog shown before requesting the OS location permission.
  ///
  /// In en, this message translates to:
  /// **'Location access needed'**
  String get locationPermissionDialogTitle;

  /// Friendly explanation of why location access is required, shown before the OS permission prompt.
  ///
  /// In en, this message translates to:
  /// **'We use your location to show free parking spots near you and let you report the ones you find. This app won\'t work without it.'**
  String get locationPermissionDialogBody;

  /// Button that proceeds from the explanation dialog to the OS permission prompt.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get locationPermissionContinue;

  /// Shown when the user denies the location permission request.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use this app.'**
  String get locationPermissionDenied;

  /// Button to re-request location permission after it was denied.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get locationPermissionRetry;

  /// Button that opens the phone's app settings screen.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locationPermissionOpenSettings;

  /// Shown when location permission has been permanently denied and can only be changed from system settings.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off for this app. Please enable it in your phone\'s settings.'**
  String get locationPermissionPermanentlyDenied;

  /// Shown when the phone's location services (GPS) are off entirely, separate from the app's own permission.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please turn them on in your phone\'s settings.'**
  String get locationServicesDisabled;

  /// Tooltip on the app bar icon that opens the account screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTooltip;

  /// Title of the account screen.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountScreenTitle;

  /// Shown on the account screen when the current user is an anonymous guest.
  ///
  /// In en, this message translates to:
  /// **'You\'re using a guest account. Create an account to keep your data if you switch phones.'**
  String get guestStatusLabel;

  /// Shown on the account screen once the guest has created or signed into a real account.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAsLabel(String email);

  /// Heading over the sign-up form.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signUpTitle;

  /// Heading over the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// Label for the email text field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Label for the password text field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Button that submits the sign-up form.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButton;

  /// Button that submits the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// Link that switches the form from sign-up mode to sign-in mode.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// Link that switches the form from sign-in mode to sign-up mode.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToSignUp;

  /// Button that signs the user out, returning them to a guest session.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// Fallback error message for unrecognized auth errors.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authGenericError;

  /// Shown when signing up with an email that's already registered.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered. Try signing in instead.'**
  String get authEmailAlreadyInUse;

  /// Shown when the chosen password is too weak.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password (at least 6 characters).'**
  String get authWeakPassword;

  /// Shown when the entered email is not validly formatted.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like a valid email address.'**
  String get authInvalidEmail;

  /// Shown when sign-in fails because the email or password is wrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authWrongCredentials;

  /// Tooltip on the button that starts the report-a-spot flow.
  ///
  /// In en, this message translates to:
  /// **'Add spot'**
  String get addSpotTooltip;

  /// Title of the camera capture screen.
  ///
  /// In en, this message translates to:
  /// **'Photograph the sign'**
  String get captureScreenTitle;

  /// Instructions shown over the camera preview.
  ///
  /// In en, this message translates to:
  /// **'Frame the parking sign clearly, then tap to capture.'**
  String get captureInstructions;

  /// Accessibility label for the shutter button.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureButtonLabel;

  /// Shown when camera permission is denied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to report a spot.'**
  String get cameraPermissionDenied;

  /// Button that opens the phone's app settings screen from the camera-denied message.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get cameraPermissionOpenSettings;

  /// Shown briefly while GPS location is captured alongside the photo.
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get capturingLocation;

  /// Shown when taking the photo fails unexpectedly.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t take the photo. Please try again.'**
  String get captureFailed;

  /// Button to discard the photo just taken and capture again.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// Button to proceed with the photo just taken.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get usePhoto;

  /// Title of the screen where the user reviews and edits the interpreted parking rules.
  ///
  /// In en, this message translates to:
  /// **'Confirm the rules'**
  String get confirmScreenTitle;

  /// Instructions at the top of the confirm/edit screen.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what we read from the sign. Edit anything that\'s not right.'**
  String get confirmInstructions;

  /// Label above the plain-language rule summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// Label above the day-of-week selector.
  ///
  /// In en, this message translates to:
  /// **'Free days'**
  String get freeDaysLabel;

  /// Label above the free-time-window controls.
  ///
  /// In en, this message translates to:
  /// **'Free hours'**
  String get freeHoursLabel;

  /// Switch that toggles between an all-day rule and a specific time window.
  ///
  /// In en, this message translates to:
  /// **'Free all day'**
  String get allDayToggleLabel;

  /// Label for the start-of-window time picker.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromTimeLabel;

  /// Label for the end-of-window time picker.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toTimeLabel;

  /// Label above the maximum-stay-duration control.
  ///
  /// In en, this message translates to:
  /// **'Max stay'**
  String get maxDurationLabel;

  /// Value shown/selected when there's no maximum stay duration.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimitLabel;

  /// A duration in minutes, e.g. '120 min'.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(int minutes);

  /// Label above the free-text exceptions field.
  ///
  /// In en, this message translates to:
  /// **'Exceptions'**
  String get exceptionsLabel;

  /// Placeholder text in the exceptions field.
  ///
  /// In en, this message translates to:
  /// **'e.g. residents exempt'**
  String get exceptionsHint;

  /// Button that submits the confirmed spot report.
  ///
  /// In en, this message translates to:
  /// **'Confirm and submit'**
  String get confirmAndSubmitButton;

  /// Button that discards the report in progress.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Confirmation shown after a spot report is successfully submitted.
  ///
  /// In en, this message translates to:
  /// **'Spot reported. Thanks for helping others find free parking!'**
  String get spotSubmittedMessage;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunday;

  /// Tooltip on the button that switches from map to list view.
  ///
  /// In en, this message translates to:
  /// **'Switch to list view'**
  String get toggleToListView;

  /// Tooltip on the button that switches from list to map view.
  ///
  /// In en, this message translates to:
  /// **'Switch to map view'**
  String get toggleToMapView;

  /// Shown when there are no reported spots within 1km.
  ///
  /// In en, this message translates to:
  /// **'No free parking spots reported nearby yet.'**
  String get noSpotsNearbyMessage;

  /// Title of the spot detail screen.
  ///
  /// In en, this message translates to:
  /// **'Parking spot'**
  String get spotDetailTitle;

  /// Shown instead of a duration when a spot was reported less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNowLabel;

  /// How long ago a spot was reported, in minutes.
  ///
  /// In en, this message translates to:
  /// **'Reported {minutes} min ago'**
  String reportedMinutesAgo(int minutes);

  /// How long ago a spot was reported, in hours.
  ///
  /// In en, this message translates to:
  /// **'Reported {hours} h ago'**
  String reportedHoursAgo(int hours);

  /// How long ago a spot was reported, in days.
  ///
  /// In en, this message translates to:
  /// **'Reported {days} d ago'**
  String reportedDaysAgo(int days);

  /// Button that starts turn-by-turn navigation to a spot.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigateButton;

  /// Title of the dialog offering a choice of maps app.
  ///
  /// In en, this message translates to:
  /// **'Choose navigation app'**
  String get chooseNavigationAppTitle;

  /// Option to navigate using Google Maps.
  ///
  /// In en, this message translates to:
  /// **'Google Maps'**
  String get googleMapsOption;

  /// Option to navigate using Apple Maps.
  ///
  /// In en, this message translates to:
  /// **'Apple Maps'**
  String get appleMapsOption;

  /// Spot status: currently free, by rule or crowd confirmation.
  ///
  /// In en, this message translates to:
  /// **'Free right now'**
  String get statusFreeNowLabel;

  /// Spot status: someone recently reported it full.
  ///
  /// In en, this message translates to:
  /// **'Reported full'**
  String get statusReportedFullLabel;

  /// Spot status: outside its free hours, or unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Not currently free'**
  String get statusNotFreeNowLabel;

  /// Distance to a spot in meters, e.g. '350 m'.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String distanceMetersValue(int value);

  /// Distance to a spot in kilometers, e.g. '0.8 km'.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String distanceKilometersValue(String value);

  /// Nudge shown to guests after a full-screen ad, encouraging them to register.
  ///
  /// In en, this message translates to:
  /// **'Tired of ads? Create a free account to remove them.'**
  String get registerToRemoveAdsMessage;

  /// Short action button label that opens the account/sign-up screen.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountAction;

  /// Button on the spot detail screen that starts the correction-report flow.
  ///
  /// In en, this message translates to:
  /// **'Report incorrect info'**
  String get reportButton;

  /// Title of the camera screen when photographing a sign to correct an existing spot.
  ///
  /// In en, this message translates to:
  /// **'Report incorrect rules'**
  String get reportScreenTitle;

  /// Instructions shown over the camera preview when reporting a correction.
  ///
  /// In en, this message translates to:
  /// **'Photograph the sign again so we can double-check the rules.'**
  String get reportInstructions;

  /// Instructions at the top of the confirm/edit screen when submitting a correction.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what we read from the sign. Edit anything that\'s not right, then submit your correction.'**
  String get reportConfirmInstructions;

  /// Button that submits a correction report for an existing spot.
  ///
  /// In en, this message translates to:
  /// **'Submit correction'**
  String get submitCorrectionButton;

  /// Confirmation shown after a correction report is successfully submitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks! Once enough people agree, we\'ll update this spot\'s info.'**
  String get correctionSubmittedMessage;
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
      <String>['en', 'fi', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
