// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Free Parking Finland';

  @override
  String get mapPlaceholderTitle => 'Karttanäkymä';

  @override
  String get mapPlaceholderSubtitle => 'Oikea kartta tulossa pian';

  @override
  String get locationPermissionDialogTitle => 'Sijaintioikeus tarvitaan';

  @override
  String get locationPermissionDialogBody =>
      'Käytämme sijaintiasi näyttääksemme lähelläsi olevat ilmaiset pysäköintipaikat ja jotta voit ilmoittaa löytämistäsi paikoista. Sovellus ei toimi ilman sitä.';

  @override
  String get locationPermissionContinue => 'Jatka';

  @override
  String get locationPermissionDenied =>
      'Sovelluksen käyttö edellyttää sijaintilupaa.';

  @override
  String get locationPermissionRetry => 'Yritä uudelleen';

  @override
  String get locationPermissionOpenSettings => 'Avaa asetukset';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Sijaintikäyttöoikeus on pois päältä tälle sovellukselle. Ota se käyttöön puhelimen asetuksista.';

  @override
  String get locationServicesDisabled =>
      'Sijaintipalvelut ovat pois päältä. Ota ne käyttöön puhelimen asetuksista.';

  @override
  String get accountTooltip => 'Tili';

  @override
  String get accountScreenTitle => 'Tili';

  @override
  String get guestStatusLabel =>
      'Käytät vierastiliä. Luo tili säilyttääksesi tietosi, jos vaihdat puhelinta.';

  @override
  String signedInAsLabel(String email) {
    return 'Kirjautuneena sisään: $email';
  }

  @override
  String get signUpTitle => 'Luo tili';

  @override
  String get signInTitle => 'Kirjaudu sisään';

  @override
  String get emailLabel => 'Sähköposti';

  @override
  String get passwordLabel => 'Salasana';

  @override
  String get signUpButton => 'Luo tili';

  @override
  String get signInButton => 'Kirjaudu sisään';

  @override
  String get switchToSignIn => 'Onko sinulla jo tili? Kirjaudu sisään';

  @override
  String get switchToSignUp => 'Uusi käyttäjä? Luo tili';

  @override
  String get signOutButton => 'Kirjaudu ulos';

  @override
  String get authGenericError => 'Jotain meni pieleen. Yritä uudelleen.';

  @override
  String get authEmailAlreadyInUse =>
      'Tämä sähköposti on jo rekisteröity. Kokeile kirjautua sisään.';

  @override
  String get authWeakPassword =>
      'Valitse vahvempi salasana (vähintään 6 merkkiä).';

  @override
  String get authInvalidEmail =>
      'Tämä ei näytä kelvolliselta sähköpostiosoitteelta.';

  @override
  String get authWrongCredentials => 'Väärä sähköposti tai salasana.';

  @override
  String get addSpotTooltip => 'Lisää paikka';

  @override
  String get captureScreenTitle => 'Kuvaa kyltti';

  @override
  String get captureInstructions =>
      'Kohdista pysäköintikyltti selvästi ja napauta kuvataksesi.';

  @override
  String get captureButtonLabel => 'Kuvaa';

  @override
  String get cameraPermissionDenied =>
      'Kameran käyttöoikeus tarvitaan paikan ilmoittamiseen.';

  @override
  String get cameraPermissionOpenSettings => 'Avaa asetukset';

  @override
  String get capturingLocation => 'Haetaan sijaintiasi...';

  @override
  String get captureFailed => 'Kuvan ottaminen epäonnistui. Yritä uudelleen.';

  @override
  String get retakePhoto => 'Ota uudelleen';

  @override
  String get usePhoto => 'Käytä tätä kuvaa';

  @override
  String get confirmScreenTitle => 'Vahvista säännöt';

  @override
  String get confirmInstructions =>
      'Tässä on, mitä luimme kyltistä. Muokkaa, jos jokin ei täsmää.';

  @override
  String get summaryLabel => 'Yhteenveto';

  @override
  String get freeDaysLabel => 'Ilmaiset päivät';

  @override
  String get freeHoursLabel => 'Ilmaiset tunnit';

  @override
  String get allDayToggleLabel => 'Ilmainen koko päivän';

  @override
  String get fromTimeLabel => 'Alkaen';

  @override
  String get toTimeLabel => 'Päättyen';

  @override
  String get maxDurationLabel => 'Enimmäisaika';

  @override
  String get noLimitLabel => 'Ei rajaa';

  @override
  String minutesValue(int minutes) {
    return '$minutes min';
  }

  @override
  String get exceptionsLabel => 'Poikkeukset';

  @override
  String get exceptionsHint => 'esim. asukkaat vapautettu';

  @override
  String get confirmAndSubmitButton => 'Vahvista ja lähetä';

  @override
  String get cancelButton => 'Peruuta';

  @override
  String get spotSubmittedMessage =>
      'Paikka ilmoitettu. Kiitos, että autat muita löytämään ilmaisen pysäköintipaikan!';

  @override
  String get dayMonday => 'Ma';

  @override
  String get dayTuesday => 'Ti';

  @override
  String get dayWednesday => 'Ke';

  @override
  String get dayThursday => 'To';

  @override
  String get dayFriday => 'Pe';

  @override
  String get daySaturday => 'La';

  @override
  String get daySunday => 'Su';

  @override
  String get toggleToListView => 'Vaihda listanäkymään';

  @override
  String get toggleToMapView => 'Vaihda karttanäkymään';

  @override
  String get noSpotsNearbyMessage =>
      'Lähistöllä ei ole vielä ilmoitettuja ilmaisia pysäköintipaikkoja.';

  @override
  String get spotDetailTitle => 'Pysäköintipaikka';

  @override
  String get justNowLabel => 'Juuri nyt';

  @override
  String reportedMinutesAgo(int minutes) {
    return 'Ilmoitettu $minutes min sitten';
  }

  @override
  String reportedHoursAgo(int hours) {
    return 'Ilmoitettu $hours t sitten';
  }

  @override
  String reportedDaysAgo(int days) {
    return 'Ilmoitettu $days pv sitten';
  }

  @override
  String get navigateButton => 'Navigoi';

  @override
  String get chooseNavigationAppTitle => 'Valitse navigointisovellus';

  @override
  String get googleMapsOption => 'Google Maps';

  @override
  String get appleMapsOption => 'Apple Maps';

  @override
  String get statusFreeNowLabel => 'Vapaa juuri nyt';

  @override
  String get statusReportedFullLabel => 'Ilmoitettu täyteen';

  @override
  String get statusNotFreeNowLabel => 'Ei tällä hetkellä vapaa';

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
      'Kyllästyitkö mainoksiin? Luo ilmainen tili poistaaksesi ne.';

  @override
  String get createAccountAction => 'Luo tili';

  @override
  String get reportButton => 'Ilmoita virheelliset tiedot';

  @override
  String get reportScreenTitle => 'Ilmoita virheelliset säännöt';

  @override
  String get reportInstructions =>
      'Valokuvaa kyltti uudelleen, jotta voimme tarkistaa säännöt.';

  @override
  String get reportConfirmInstructions =>
      'Tässä on mitä luimme kyltistä. Muokkaa mikä ei ole oikein ja lähetä korjauksesi.';

  @override
  String get submitCorrectionButton => 'Lähetä korjaus';

  @override
  String get correctionSubmittedMessage =>
      'Kiitos! Kun tarpeeksi moni on samaa mieltä, päivitämme tämän paikan tiedot.';
}
