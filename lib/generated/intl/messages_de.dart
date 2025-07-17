// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(distance) => "${distance}m entfernt";

  static String m1(error) => "Fehler: ${error}";

  static String m2(error) => "Fehler: ${error}";

  static String m3(diamonds) => "Kaufen für ${diamonds} 💎";

  static String m4(count) => "${count} Kommentare";

  static String m5(count) => "Diamanten";

  static String m6(error) => "Fehler: ${error}";

  static String m7(error) => "❌ Fehler beim Speichern des Videos: ${error}";

  static String m8(intent) => "Absicht: ${intent}";

  static String m9(intent) => "Suche nach ${intent} in der Nähe";

  static String m10(emoji) => "${emoji} Match gefunden!";

  static String m11(emoji, mood) => "Stimmung";

  static String m12(price) => "Vorgeschlagener Preis: ${price} 💎";

  static String m13(error) => "Aufnahmefehler: ${error}";

  static String m14(count) =>
      "${count} ${Intl.plural(count, one: 'Antwort', other: 'Antworten')}";

  static String m15(username) => "Antwort auf ${username}";

  static String m16(email) => "📧 Zurücksetzungs-E-Mail gesendet an ${email}";

  static String m17(error) => "Auswahlfehler: ${error}";

  static String m18(caption, username) =>
      "🎬 Schau dir dieses Video auf Dadadu an!\n\"${caption}\"\nVon @${username}\n\n📱 Authentische Video-App ohne Likes oder Views\n#Dadadu #Authentisch #Lokal";

  static String m19(error) => "❌ Fehler beim Teilen: ${error}";

  static String m20(error) => "Fehler beim Teilen: ${error}";

  static String m21(username) => "Dadadu-Profil von ${username}";

  static String m22(username, profileUrl) =>
      "🎬 Schau dir das Profil von ${username} auf Dadadu an!\nEine App für authentische Kurzvideos ohne Likes oder Aufrufe.\n${profileUrl}\n\n#Dadadu #Profil";

  static String m23(referralLink) =>
      "🎬 Komm zu Dadadu! Eine App für Kurzvideos ohne Likes, nur echte Inhalte. Nutze meinen Empfehlungslink und erhalte 100 💎: ${referralLink}\n\n#Dadadu #Echt #KeineAufrufe";

  static String m24(error) => "Fehler beim Beenden der Aufnahme: ${error}";

  static String m25(username) => "${username} hat dein Video kommentiert";

  static String m26(error) => "Video-Ladefehler: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addComment": MessageLookupByLibrary.simpleMessage(
      "Einen Kommentar hinzufügen...",
    ),
    "away": m0,
    "badgeDadalordDesc": MessageLookupByLibrary.simpleMessage(
      "Elite-Status im Wert von über \\\$10.000 mit +2 % je Million Diamanten",
    ),
    "badgeDadalordTitle": MessageLookupByLibrary.simpleMessage(
      "DADALORD (10M+)",
    ),
    "badgeFiveleafDesc": MessageLookupByLibrary.simpleMessage(
      "Beliebter Creator-Status",
    ),
    "badgeFiveleafTitle": MessageLookupByLibrary.simpleMessage(
      "FÜNFBLATT (1M–9,9M)",
    ),
    "badgeLeafDesc": MessageLookupByLibrary.simpleMessage(
      "Einstiegslevel für neue Nutzer",
    ),
    "badgeLeafTitle": MessageLookupByLibrary.simpleMessage(
      "BLATT (0–9.999 Diamanten)",
    ),
    "badgeListed": MessageLookupByLibrary.simpleMessage(
      "Abzeichen erfolgreich zum Verkauf angeboten!",
    ),
    "badgeListingError": m1,
    "badgeMarketplace": MessageLookupByLibrary.simpleMessage(
      "Abzeichen-Marktplatz",
    ),
    "badgeNote": MessageLookupByLibrary.simpleMessage(
      "📈 Höhere Abzeichen = mehr Prestige + Marktwert",
    ),
    "badgePurchaseError": m2,
    "badgePurchased": MessageLookupByLibrary.simpleMessage(
      "Abzeichen erfolgreich gekauft!",
    ),
    "badgeSystemTitle": MessageLookupByLibrary.simpleMessage(
      "🏆 DADADU-ABZEICHENSYSTEM",
    ),
    "badgeThreeleafDesc": MessageLookupByLibrary.simpleMessage(
      "Aktives Community-Mitglied",
    ),
    "badgeThreeleafTitle": MessageLookupByLibrary.simpleMessage(
      "DREIBLATT (10K–999K)",
    ),
    "buy": MessageLookupByLibrary.simpleMessage("Kaufen"),
    "buyForDiamonds": m3,
    "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "cancelSearch": MessageLookupByLibrary.simpleMessage("Suche abbrechen"),
    "captionHint": MessageLookupByLibrary.simpleMessage(
      "Beschreibe dein Video...\nWas möchtest du teilen?",
    ),
    "changePassword": MessageLookupByLibrary.simpleMessage("Passwort ändern"),
    "changeUsername": MessageLookupByLibrary.simpleMessage(
      "Benutzernamen ändern",
    ),
    "changeUsernameHint": MessageLookupByLibrary.simpleMessage(
      "Gib deinen neuen Namen ein",
    ),
    "changeUsernameTitle": MessageLookupByLibrary.simpleMessage(
      "Neuer Benutzername",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "commentError": MessageLookupByLibrary.simpleMessage("Fehler beim Senden"),
    "commentPosted": MessageLookupByLibrary.simpleMessage(
      "💬 Kommentar veröffentlicht!",
    ),
    "commentsCount": m4,
    "commentsTitle": MessageLookupByLibrary.simpleMessage("💬 Kommentare"),
    "confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "contactLabel": MessageLookupByLibrary.simpleMessage("Kontakt für Matches"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Link kopieren"),
    "createDadaduVideo": MessageLookupByLibrary.simpleMessage(
      "Erstelle dein Dadadu-Video",
    ),
    "createVideoTitle": MessageLookupByLibrary.simpleMessage("Video erstellen"),
    "createYourDadaduID": MessageLookupByLibrary.simpleMessage(
      "Erstelle deine Dadadu-ID 🚀",
    ),
    "creating": MessageLookupByLibrary.simpleMessage("Wird erstellt..."),
    "creator": MessageLookupByLibrary.simpleMessage("ERSTELLER"),
    "cropAndSave": MessageLookupByLibrary.simpleMessage(
      "Zuschneiden & Speichern",
    ),
    "cropFailed": MessageLookupByLibrary.simpleMessage(
      "Bild konnte nicht zugeschnitten werden",
    ),
    "cropImage": MessageLookupByLibrary.simpleMessage("Bild zuschneiden"),
    "cropping": MessageLookupByLibrary.simpleMessage("Zuschneiden..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dunkler Modus"),
    "delete": MessageLookupByLibrary.simpleMessage("Löschen"),
    "descriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Beschreibung (optional)",
    ),
    "diamonds": m5,
    "diamondsProfile": MessageLookupByLibrary.simpleMessage("Diamanten"),
    "discover": MessageLookupByLibrary.simpleMessage("Entdecken"),
    "discoverConfigError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Speichern der Konfiguration",
    ),
    "discoverConfigTitle": MessageLookupByLibrary.simpleMessage(
      "Discover-Konfiguration",
    ),
    "discoverConfigUpdated": MessageLookupByLibrary.simpleMessage(
      "🎯 Discover-Konfiguration aktualisiert",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Herunterladen"),
    "downloading": MessageLookupByLibrary.simpleMessage(
      "📥 Wird heruntergeladen...",
    ),
    "email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "enterOtpMessage": MessageLookupByLibrary.simpleMessage(
      "Gib den an dein Telefon gesendeten Code ein",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "errorRemovingListing": m6,
    "errorSavingVideo": m7,
    "feedAnalyzingPreferences": MessageLookupByLibrary.simpleMessage(
      "Analyse deiner Vorlieben",
    ),
    "feedPersonalizing": MessageLookupByLibrary.simpleMessage(
      "Personalisierung deines Feeds...",
    ),
    "follow": MessageLookupByLibrary.simpleMessage("Folgen"),
    "followCreators": MessageLookupByLibrary.simpleMessage(
      "Folge Erstellern, um ihre Inhalte zu sehen",
    ),
    "followers": MessageLookupByLibrary.simpleMessage("Follower"),
    "following": MessageLookupByLibrary.simpleMessage("Folgt"),
    "followingStatus": MessageLookupByLibrary.simpleMessage("Folgt"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "generalSection": MessageLookupByLibrary.simpleMessage("Allgemein"),
    "genericError": MessageLookupByLibrary.simpleMessage(
      "Ein Fehler ist aufgetreten. Bitte versuche es erneut.",
    ),
    "goodMatch": MessageLookupByLibrary.simpleMessage("Gutes Match"),
    "gotIt": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "greatButton": MessageLookupByLibrary.simpleMessage("Super!"),
    "greatMatch": MessageLookupByLibrary.simpleMessage("Tolles Match"),
    "howBadgesWork": MessageLookupByLibrary.simpleMessage(
      "Wie Abzeichen funktionieren",
    ),
    "identifierHint": MessageLookupByLibrary.simpleMessage("Dein Benutzername"),
    "imageReady": MessageLookupByLibrary.simpleMessage("Bild bereit!"),
    "imageSelectionError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Auswählen des Bildes",
    ),
    "infoAddCaption": MessageLookupByLibrary.simpleMessage(
      "Fügen Sie eine Beschreibung hinzu, um Ihr Video zu veröffentlichen",
    ),
    "infoSelectOrRecord": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie ein Video aus oder nehmen Sie eins auf, um zu beginnen",
    ),
    "initializingCamera": MessageLookupByLibrary.simpleMessage(
      "Kamera wird initialisiert...",
    ),
    "intent": MessageLookupByLibrary.simpleMessage("Absicht"),
    "intentBusiness": MessageLookupByLibrary.simpleMessage("Business"),
    "intentEntertainment": MessageLookupByLibrary.simpleMessage("Unterhaltung"),
    "intentFun": MessageLookupByLibrary.simpleMessage("Spaß"),
    "intentInformative": MessageLookupByLibrary.simpleMessage("Informativ"),
    "intentLove": MessageLookupByLibrary.simpleMessage("Liebe"),
    "intentSerious": MessageLookupByLibrary.simpleMessage("Ernst"),
    "intentWith": m8,
    "interestFailed": MessageLookupByLibrary.simpleMessage(
      "Interesse konnte nicht ausgedrückt werden",
    ),
    "interestSentWaiting": MessageLookupByLibrary.simpleMessage(
      "Interesse gesendet! Warte auf Antwort...",
    ),
    "interested": MessageLookupByLibrary.simpleMessage("Ich bin interessiert"),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Bitte eine gültige Telefonnummer eingeben (mit +Ländervorwahl)",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Sprache"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Heller Modus"),
    "listingRemoved": MessageLookupByLibrary.simpleMessage("Anzeige entfernt"),
    "loading": MessageLookupByLibrary.simpleMessage("Wird geladen..."),
    "loadingImage": MessageLookupByLibrary.simpleMessage(
      "Bild wird geladen...",
    ),
    "locationPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "📍 Standortzugriff erforderlich, um Nutzer in der Nähe zu finden",
    ),
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Standortberechtigung erforderlich für die Partnersuche",
    ),
    "login": MessageLookupByLibrary.simpleMessage("ANMELDEN"),
    "logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Möchten Sie sich wirklich abmelden?",
    ),
    "logoutDescription": MessageLookupByLibrary.simpleMessage("App verlassen"),
    "lookingForIntentNearby": m9,
    "matchFound": m10,
    "matchHistory": MessageLookupByLibrary.simpleMessage("Match-Historie"),
    "matchedWith": MessageLookupByLibrary.simpleMessage("Gepaart mit"),
    "maximum20Seconds": MessageLookupByLibrary.simpleMessage(
      "Maximal 20 Sekunden",
    ),
    "mood": m11,
    "moodProfile": MessageLookupByLibrary.simpleMessage("Stimmung"),
    "mustBeLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Du musst angemeldet sein, um zu kommentieren",
    ),
    "mutualMatchTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Gegenseitiges Match!",
    ),
    "myBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "Meine Abzeichen zum Verkauf",
    ),
    "myVideos": MessageLookupByLibrary.simpleMessage("Meine Videos"),
    "navNow": MessageLookupByLibrary.simpleMessage("Jetzt"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "navUpload": MessageLookupByLibrary.simpleMessage("Hochladen"),
    "newCommentNotification": MessageLookupByLibrary.simpleMessage(
      "💬 Neuer Kommentar",
    ),
    "newUsernameHint": MessageLookupByLibrary.simpleMessage(
      "Neuer Benutzername",
    ),
    "noAccountSignUp": MessageLookupByLibrary.simpleMessage(
      "Noch kein Konto? Jetzt registrieren",
    ),
    "noBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "Keine Abzeichen zum Verkauf",
    ),
    "noCommentsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Teile deine Gedanken zu diesem Video",
    ),
    "noCommentsTitle": MessageLookupByLibrary.simpleMessage(
      "Sei der Erste, der kommentiert!",
    ),
    "noContactInfo": MessageLookupByLibrary.simpleMessage(
      "Keine Kontaktinformationen",
    ),
    "noImageLoaded": MessageLookupByLibrary.simpleMessage("Kein Bild geladen"),
    "noMatchHistory": MessageLookupByLibrary.simpleMessage(
      "Keine Match-Historie.",
    ),
    "noMatchesFoundNearby": MessageLookupByLibrary.simpleMessage(
      "Keine passenden Personen in der Nähe gefunden",
    ),
    "noPhoto": MessageLookupByLibrary.simpleMessage("Kein Foto"),
    "noVideoSelected": MessageLookupByLibrary.simpleMessage(
      "Keine Video ausgewählt",
    ),
    "noVideos": MessageLookupByLibrary.simpleMessage("Keine Videos verfügbar"),
    "notConfigured": MessageLookupByLibrary.simpleMessage("Nicht konfiguriert"),
    "notDefined": MessageLookupByLibrary.simpleMessage("Nicht festgelegt"),
    "notEnoughDiamonds": MessageLookupByLibrary.simpleMessage(
      "Du hast nicht genug Diamanten!",
    ),
    "nowLabel": MessageLookupByLibrary.simpleMessage("Jetzt"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "other": MessageLookupByLibrary.simpleMessage("Andere"),
    "otpError": MessageLookupByLibrary.simpleMessage(
      "Falscher Code. Bitte erneut versuchen.",
    ),
    "otpHint": MessageLookupByLibrary.simpleMessage("6-stelliger Code"),
    "ownBadgeSellError": MessageLookupByLibrary.simpleMessage(
      "Du kannst nur deine eigenen Abzeichen verkaufen",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "perfectMatch": MessageLookupByLibrary.simpleMessage("Perfektes Match"),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "❌ Speicherberechtigung erforderlich",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Telefon"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Telefonnummer"),
    "photoSet": MessageLookupByLibrary.simpleMessage("Foto festgelegt"),
    "pleaseAddCaption": MessageLookupByLibrary.simpleMessage(
      "Bitte fügen Sie eine Beschreibung hinzu",
    ),
    "priceHint": m12,
    "priceLabel": MessageLookupByLibrary.simpleMessage("Preis in Diamanten"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profilePhoto": MessageLookupByLibrary.simpleMessage("Profilfoto"),
    "profilePhotoRemoveError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Entfernen des Profilbilds",
    ),
    "profilePhotoRemoved": MessageLookupByLibrary.simpleMessage(
      "✅ Profilbild wurde entfernt",
    ),
    "profilePhotoUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Hochladen des Profilbilds",
    ),
    "profilePhotoUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Profilbild aktualisiert",
    ),
    "profileSection": MessageLookupByLibrary.simpleMessage("Profil"),
    "publishVideoButton": MessageLookupByLibrary.simpleMessage(
      "VIDEO VERÖFFENTLICHEN",
    ),
    "rank": MessageLookupByLibrary.simpleMessage("Rang"),
    "recordingError": m13,
    "redo": MessageLookupByLibrary.simpleMessage("Wiederholen"),
    "referFriends": MessageLookupByLibrary.simpleMessage("Freunde einladen"),
    "referralDescription": MessageLookupByLibrary.simpleMessage(
      "Erhalte 100 Diamanten für jeden Freund, der mit deinem Code zu Dadadu kommt!",
    ),
    "referralLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Empfehlungslink kopiert! 📋",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "repliesCount": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Antworten"),
    "replyToComment": MessageLookupByLibrary.simpleMessage(
      "Auf Kommentar antworten...",
    ),
    "replyingTo": m15,
    "resetEmailError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Senden der Zurücksetzungs-E-Mail",
    ),
    "resetEmailSent": m16,
    "save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Speichern"),
    "scanningForConnections": MessageLookupByLibrary.simpleMessage(
      "Suche nach Verbindungen...",
    ),
    "searchFailed": MessageLookupByLibrary.simpleMessage(
      "Suche fehlgeschlagen",
    ),
    "securitySection": MessageLookupByLibrary.simpleMessage("Sicherheit"),
    "selectIntent": MessageLookupByLibrary.simpleMessage("Wähle deine Absicht"),
    "selectionError": m17,
    "sell": MessageLookupByLibrary.simpleMessage("Verkaufen"),
    "sellBadgeTitle": MessageLookupByLibrary.simpleMessage(
      "Verkaufe dein Abzeichen",
    ),
    "sellButton": MessageLookupByLibrary.simpleMessage("Zum Verkauf anbieten"),
    "sellCurrentBadgeTitle": MessageLookupByLibrary.simpleMessage(
      "Mein aktuelles Abzeichen verkaufen",
    ),
    "sendResetEmail": MessageLookupByLibrary.simpleMessage(
      "Passwort-Reset-E-Mail senden",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "setupDiscover": MessageLookupByLibrary.simpleMessage(
      "Discover konfigurieren",
    ),
    "share": MessageLookupByLibrary.simpleMessage("Teilen"),
    "shareBaseText": m18,
    "shareError": m19,
    "shareFacebookSuffix": MessageLookupByLibrary.simpleMessage(
      "🌟 Mach mit bei der authentischen Content-Revolution!",
    ),
    "shareInstagramSuffix": MessageLookupByLibrary.simpleMessage(
      "📲 #DadaduApp #KeineLikes #EchterContent",
    ),
    "shareProfileError": m20,
    "shareProfileSubject": m21,
    "shareProfileText": m22,
    "shareReferralSubject": MessageLookupByLibrary.simpleMessage(
      "Komm zu Dadadu!",
    ),
    "shareReferralText": m23,
    "shareSnapchatSuffix": MessageLookupByLibrary.simpleMessage(
      "👻 Kein Algorithmus mehr, nur echt!",
    ),
    "shareVideo": MessageLookupByLibrary.simpleMessage(
      "📤 Dieses Video teilen",
    ),
    "shareWhatsAppSuffix": MessageLookupByLibrary.simpleMessage(
      "💎 Lade Dadadu herunter und sammle Diamanten!",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("REGISTRIEREN"),
    "skip": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "socialNetworkLabel": MessageLookupByLibrary.simpleMessage(
      "Soziales Netzwerk",
    ),
    "sortPopular": MessageLookupByLibrary.simpleMessage("🔥 Beliebt"),
    "sortRecent": MessageLookupByLibrary.simpleMessage("🕒 Neueste"),
    "sortTrending": MessageLookupByLibrary.simpleMessage("📈 Im Trend"),
    "stopRecordingError": m24,
    "theme": MessageLookupByLibrary.simpleMessage("Thema"),
    "trimContinue": MessageLookupByLibrary.simpleMessage(
      "Zuschneiden & weiter",
    ),
    "trimTitle": MessageLookupByLibrary.simpleMessage("Video zuschneiden"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "tryChangingIntentOrLater": MessageLookupByLibrary.simpleMessage(
      "Versuche es mit einer anderen Absicht oder später erneut",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Rückgängig"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unbekannt"),
    "uploadError": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Hochladen",
    ),
    "user": MessageLookupByLibrary.simpleMessage("Benutzer"),
    "userCommented": m25,
    "userNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Benutzer nicht angemeldet",
    ),
    "userProfileNotFound": MessageLookupByLibrary.simpleMessage(
      "Benutzerprofil nicht gefunden",
    ),
    "userUnknown": MessageLookupByLibrary.simpleMessage("Benutzer"),
    "username": MessageLookupByLibrary.simpleMessage("Benutzername"),
    "usernameUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Fehler beim Aktualisieren des Benutzernamens",
    ),
    "usernameUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Benutzername aktualisiert",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "videoIntent": MessageLookupByLibrary.simpleMessage("Videoabsicht"),
    "videoLoadingError": m26,
    "videoPublishedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "🎉 Video erfolgreich veröffentlicht!",
    ),
    "videoSaved": MessageLookupByLibrary.simpleMessage(
      "✅ In Downloads gespeichert!",
    ),
    "videos": MessageLookupByLibrary.simpleMessage("Videos"),
    "videosOf": MessageLookupByLibrary.simpleMessage("Videos von"),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Willkommen zurück 👽"),
    "welcomeLogin": MessageLookupByLibrary.simpleMessage(
      "Willkommen! Bitte melden Sie sich an",
    ),
    "welcomeSignUp": MessageLookupByLibrary.simpleMessage("Registrieren"),
    "welcomeToDadadu": MessageLookupByLibrary.simpleMessage(
      "Willkommen bei Dadadu",
    ),
    "whatsYourVibe": MessageLookupByLibrary.simpleMessage(
      "Wie ist deine Stimmung heute?",
    ),
    "yourBadge": MessageLookupByLibrary.simpleMessage("Dein Abzeichen"),
  };
}
