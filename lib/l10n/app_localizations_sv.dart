// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Free Parking Finland';

  @override
  String get mapPlaceholderTitle => 'Kartvy';

  @override
  String get mapPlaceholderSubtitle => 'Riktig karta kommer snart';

  @override
  String get locationPermissionDialogTitle => 'Platsåtkomst behövs';

  @override
  String get locationPermissionDialogBody =>
      'Vi använder din plats för att visa gratis parkeringsplatser nära dig och låta dig rapportera platser du hittar. Appen fungerar inte utan den.';

  @override
  String get locationPermissionContinue => 'Fortsätt';

  @override
  String get locationPermissionDenied =>
      'Platsbehörighet krävs för att använda appen.';

  @override
  String get locationPermissionRetry => 'Försök igen';

  @override
  String get locationPermissionOpenSettings => 'Öppna inställningar';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Platsåtkomst är avstängd för den här appen. Aktivera den i telefonens inställningar.';

  @override
  String get locationServicesDisabled =>
      'Platstjänster är avstängda. Aktivera dem i telefonens inställningar.';

  @override
  String get accountTooltip => 'Konto';

  @override
  String get accountScreenTitle => 'Konto';

  @override
  String get guestStatusLabel =>
      'Du använder ett gästkonto. Skapa ett konto för att behålla dina uppgifter om du byter telefon.';

  @override
  String signedInAsLabel(String email) {
    return 'Inloggad som $email';
  }

  @override
  String get signUpTitle => 'Skapa ett konto';

  @override
  String get signInTitle => 'Logga in';

  @override
  String get emailLabel => 'E-post';

  @override
  String get passwordLabel => 'Lösenord';

  @override
  String get signUpButton => 'Registrera';

  @override
  String get signInButton => 'Logga in';

  @override
  String get switchToSignIn => 'Har du redan ett konto? Logga in';

  @override
  String get switchToSignUp => 'Ny här? Skapa ett konto';

  @override
  String get signOutButton => 'Logga ut';

  @override
  String get authGenericError => 'Något gick fel. Försök igen.';

  @override
  String get authEmailAlreadyInUse =>
      'Den e-postadressen är redan registrerad. Prova att logga in istället.';

  @override
  String get authWeakPassword => 'Välj ett starkare lösenord (minst 6 tecken).';

  @override
  String get authInvalidEmail => 'Det ser inte ut som en giltig e-postadress.';

  @override
  String get authWrongCredentials => 'Fel e-post eller lösenord.';

  @override
  String get addSpotTooltip => 'Lägg till plats';

  @override
  String get captureScreenTitle => 'Fotografera skylten';

  @override
  String get captureInstructions =>
      'Rikta in parkeringsskylten tydligt och tryck för att fotografera.';

  @override
  String get captureButtonLabel => 'Fotografera';

  @override
  String get cameraPermissionDenied =>
      'Kameråtkomst behövs för att rapportera en plats.';

  @override
  String get cameraPermissionOpenSettings => 'Öppna inställningar';

  @override
  String get capturingLocation => 'Hämtar din plats...';

  @override
  String get captureFailed => 'Det gick inte att ta bilden. Försök igen.';

  @override
  String get retakePhoto => 'Ta om';

  @override
  String get usePhoto => 'Använd denna bild';

  @override
  String get confirmScreenTitle => 'Bekräfta reglerna';

  @override
  String get confirmInstructions =>
      'Så här läste vi skylten. Redigera det som inte stämmer.';

  @override
  String get summaryLabel => 'Sammanfattning';

  @override
  String get freeDaysLabel => 'Gratis dagar';

  @override
  String get freeHoursLabel => 'Gratis timmar';

  @override
  String get allDayToggleLabel => 'Gratis hela dagen';

  @override
  String get fromTimeLabel => 'Från';

  @override
  String get toTimeLabel => 'Till';

  @override
  String get maxDurationLabel => 'Max vistelsetid';

  @override
  String get noLimitLabel => 'Ingen gräns';

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get exceptionsLabel => 'Undantag';

  @override
  String get exceptionsHint => 't.ex. boende undantagna';

  @override
  String get confirmAndSubmitButton => 'Bekräfta och skicka';

  @override
  String get cancelButton => 'Avbryt';

  @override
  String get spotSubmittedMessage =>
      'Platsen rapporterad. Tack för att du hjälper andra hitta gratis parkering!';

  @override
  String get dayMonday => 'Mån';

  @override
  String get dayTuesday => 'Tis';

  @override
  String get dayWednesday => 'Ons';

  @override
  String get dayThursday => 'Tors';

  @override
  String get dayFriday => 'Fre';

  @override
  String get daySaturday => 'Lör';

  @override
  String get daySunday => 'Sön';

  @override
  String get toggleToListView => 'Byt till listvy';

  @override
  String get toggleToMapView => 'Byt till kartvy';

  @override
  String get noSpotsNearbyMessage =>
      'Inga gratis parkeringsplatser rapporterade i närheten än.';

  @override
  String get spotDetailTitle => 'Parkeringsplats';

  @override
  String get justNowLabel => 'Just nu';

  @override
  String reportedMinutesAgo(int minutes) {
    return 'Rapporterad för $minutes min sedan';
  }

  @override
  String reportedHoursAgo(int hours) {
    return 'Rapporterad för $hours tim sedan';
  }

  @override
  String reportedDaysAgo(int days) {
    return 'Rapporterad för $days dagar sedan';
  }

  @override
  String get navigateButton => 'Navigera';

  @override
  String get chooseNavigationAppTitle => 'Välj navigeringsapp';

  @override
  String get googleMapsOption => 'Google Maps';

  @override
  String get appleMapsOption => 'Apple Maps';

  @override
  String get statusFreeNowLabel => 'Ledig just nu';

  @override
  String get statusReportedFullLabel => 'Rapporterad full';

  @override
  String get statusNotFreeNowLabel => 'Inte ledig just nu';

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
      'Trött på annonser? Skapa ett gratis konto för att ta bort dem.';

  @override
  String get createAccountAction => 'Skapa konto';

  @override
  String get reportButton => 'Rapportera felaktig information';

  @override
  String get reportScreenTitle => 'Rapportera felaktiga regler';

  @override
  String get reportInstructions =>
      'Fotografera skylten igen så vi kan dubbelkolla reglerna.';

  @override
  String get reportConfirmInstructions =>
      'Här är vad vi läste från skylten. Redigera det som inte stämmer och skicka din rättelse.';

  @override
  String get submitCorrectionButton => 'Skicka rättelse';

  @override
  String get correctionSubmittedMessage =>
      'Tack! När tillräckligt många är överens uppdaterar vi denna plats information.';
}
