// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(distance) => "${distance}m de distance";

  static String m1(error) => "Erreur : ${error}";

  static String m2(error) => "Erreur : ${error}";

  static String m3(diamonds) => "Acheter ${diamonds} 💎";

  static String m4(count) => "${count} commentaires";

  static String m5(count) => "Diamants";

  static String m6(error) => "Erreur : ${error}";

  static String m7(error) => "❌ Erreur lors de l\'enregistrement : ${error}";

  static String m8(intent) => "Intent : ${intent}";

  static String m9(intent) => "Recherche de ${intent} à proximité";

  static String m10(emoji) => "${emoji} Correspondance trouvée !";

  static String m11(emoji, mood) => "Humeur";

  static String m12(price) => "Prix suggéré: ${price} 💎";

  static String m13(error) => "Erreur d\'enregistrement : ${error}";

  static String m14(count) =>
      "${count} ${Intl.plural(count, one: 'réponse', other: 'réponses')}";

  static String m15(username) => "Réponse à ${username}";

  static String m16(email) => "📧 Email de réinitialisation envoyé à ${email}";

  static String m17(error) => "Erreur de sélection : ${error}";

  static String m18(caption, username) =>
      "🎬 Regarde cette vidéo sur Dadadu !\n\"${caption}\"\nPar @${username}\n\n📱 Appli vidéo authentique sans likes ni vues\n#Dadadu #Authentique #Local";

  static String m19(error) => "❌ Erreur de partage : ${error}";

  static String m20(error) => "Erreur lors du partage: ${error}";

  static String m21(username) => "Profil Dadadu de ${username}";

  static String m22(username, profileUrl) =>
      "🎬 Découvre le profil de ${username} sur Dadadu !\nUne app de vidéos courtes authentiques sans likes ni vues.\n${profileUrl}\n\n#Dadadu #Profile";

  static String m23(referralLink) =>
      "🎬 Rejoins-moi sur Dadadu ! Une app de vidéos courtes sans likes, juste de l\'authenticité locale. Utilise mon code de parrainage pour gagner 100 💎 : ${referralLink}\n\n#Dadadu #Authentique #PasDeVues";

  static String m24(error) =>
      "Erreur lors de l\'arrêt de l\'enregistrement : ${error}";

  static String m25(username) => "${username} a commenté votre vidéo";

  static String m26(error) => "Erreur de chargement vidéo : ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addComment": MessageLookupByLibrary.simpleMessage(
      "Ajouter un commentaire...",
    ),
    "away": m0,
    "badgeDadalordDesc": MessageLookupByLibrary.simpleMessage(
      "Statut élite d\'une valeur de \\\$10 000+ avec +2% par million de diamants",
    ),
    "badgeDadalordTitle": MessageLookupByLibrary.simpleMessage(
      "DADALORD (10M+)",
    ),
    "badgeFiveleafDesc": MessageLookupByLibrary.simpleMessage(
      "Statut de créateur populaire",
    ),
    "badgeFiveleafTitle": MessageLookupByLibrary.simpleMessage(
      "CINQFEUILLES (1M–9,9M)",
    ),
    "badgeLeafDesc": MessageLookupByLibrary.simpleMessage(
      "Niveau de départ pour les nouveaux utilisateurs",
    ),
    "badgeLeafTitle": MessageLookupByLibrary.simpleMessage(
      "FEUILLE (0–9 999 diamants)",
    ),
    "badgeListed": MessageLookupByLibrary.simpleMessage(
      "Badge mis en vente avec succès !",
    ),
    "badgeListingError": m1,
    "badgeMarketplace": MessageLookupByLibrary.simpleMessage(
      "Marché des badges",
    ),
    "badgeNote": MessageLookupByLibrary.simpleMessage(
      "📈 Les badges plus élevés = plus de prestige + valeur sur le marketplace",
    ),
    "badgePurchaseError": m2,
    "badgePurchased": MessageLookupByLibrary.simpleMessage(
      "Badge acheté avec succès !",
    ),
    "badgeSystemTitle": MessageLookupByLibrary.simpleMessage(
      "🏆 SYSTÈME DE BADGES DADADU",
    ),
    "badgeThreeleafDesc": MessageLookupByLibrary.simpleMessage(
      "Membre actif de la communauté",
    ),
    "badgeThreeleafTitle": MessageLookupByLibrary.simpleMessage(
      "TREFLE (10K–999K)",
    ),
    "buy": MessageLookupByLibrary.simpleMessage("Acheter"),
    "buyForDiamonds": m3,
    "camera": MessageLookupByLibrary.simpleMessage("Caméra"),
    "cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "cancelSearch": MessageLookupByLibrary.simpleMessage(
      "Annuler la recherche",
    ),
    "captionHint": MessageLookupByLibrary.simpleMessage(
      "Décrivez votre vidéo...\nQue voulez-vous partager ?",
    ),
    "changePassword": MessageLookupByLibrary.simpleMessage(
      "Changer mot de passe",
    ),
    "changeUsername": MessageLookupByLibrary.simpleMessage(
      "Changer le nom d\'utilisateur",
    ),
    "changeUsernameHint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre nouveau nom",
    ),
    "changeUsernameTitle": MessageLookupByLibrary.simpleMessage(
      "Nouveau nom d\'utilisateur",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Fermer"),
    "commentError": MessageLookupByLibrary.simpleMessage(
      "Erreur lors de l\'envoi",
    ),
    "commentPosted": MessageLookupByLibrary.simpleMessage(
      "💬 Commentaire publié !",
    ),
    "commentsCount": m4,
    "commentsTitle": MessageLookupByLibrary.simpleMessage("💬 Commentaires"),
    "confirm": MessageLookupByLibrary.simpleMessage("Valider"),
    "contactLabel": MessageLookupByLibrary.simpleMessage(
      "Contact pour les matchs",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copier le lien"),
    "createDadaduVideo": MessageLookupByLibrary.simpleMessage(
      "Créez votre vidéo Dadadu",
    ),
    "createVideoTitle": MessageLookupByLibrary.simpleMessage("Créer une vidéo"),
    "createYourDadaduID": MessageLookupByLibrary.simpleMessage(
      "Crée ton ID Dadadu 🚀",
    ),
    "creating": MessageLookupByLibrary.simpleMessage("Création en cours..."),
    "creator": MessageLookupByLibrary.simpleMessage("CRÉATEUR"),
    "cropAndSave": MessageLookupByLibrary.simpleMessage(
      "Rogner et enregistrer",
    ),
    "cropFailed": MessageLookupByLibrary.simpleMessage(
      "Échec du rognage de l\'image",
    ),
    "cropImage": MessageLookupByLibrary.simpleMessage("Rogner l\'image"),
    "cropping": MessageLookupByLibrary.simpleMessage("Rognage..."),
    "darkMode": MessageLookupByLibrary.simpleMessage("Mode sombre"),
    "delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "descriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description (optionnelle)",
    ),
    "diamonds": m5,
    "diamondsProfile": MessageLookupByLibrary.simpleMessage("Diamants"),
    "discover": MessageLookupByLibrary.simpleMessage("Découvrir"),
    "discoverConfigError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de la sauvegarde",
    ),
    "discoverConfigTitle": MessageLookupByLibrary.simpleMessage(
      "Configuration Discover",
    ),
    "discoverConfigUpdated": MessageLookupByLibrary.simpleMessage(
      "🎯 Configuration Discover mise à jour",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Télécharger"),
    "downloading": MessageLookupByLibrary.simpleMessage("📥 Téléchargement..."),
    "email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "enterOtpMessage": MessageLookupByLibrary.simpleMessage(
      "Entrez le code envoyé à votre téléphone",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Erreur"),
    "errorRemovingListing": m6,
    "errorSavingVideo": m7,
    "feedAnalyzingPreferences": MessageLookupByLibrary.simpleMessage(
      "Analyse de vos préférences",
    ),
    "feedPersonalizing": MessageLookupByLibrary.simpleMessage(
      "Personnalisation du feed...",
    ),
    "follow": MessageLookupByLibrary.simpleMessage("Suivre"),
    "followCreators": MessageLookupByLibrary.simpleMessage(
      "Suivez des créateurs pour voir leur contenu",
    ),
    "followers": MessageLookupByLibrary.simpleMessage("Abonnés"),
    "following": MessageLookupByLibrary.simpleMessage("Abonnements"),
    "followingStatus": MessageLookupByLibrary.simpleMessage("Abonné"),
    "gallery": MessageLookupByLibrary.simpleMessage("Galerie"),
    "generalSection": MessageLookupByLibrary.simpleMessage("Général"),
    "genericError": MessageLookupByLibrary.simpleMessage(
      "Une erreur est survenue. Veuillez réessayer.",
    ),
    "goodMatch": MessageLookupByLibrary.simpleMessage(
      "Correspondance correcte",
    ),
    "gotIt": MessageLookupByLibrary.simpleMessage("Compris"),
    "greatButton": MessageLookupByLibrary.simpleMessage("Génial !"),
    "greatMatch": MessageLookupByLibrary.simpleMessage("Bonne correspondance"),
    "howBadgesWork": MessageLookupByLibrary.simpleMessage(
      "Comment fonctionnent les badges",
    ),
    "identifierHint": MessageLookupByLibrary.simpleMessage("Ton identifiant"),
    "imageReady": MessageLookupByLibrary.simpleMessage("Image prête !"),
    "imageSelectionError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de la sélection de l\'image",
    ),
    "infoAddCaption": MessageLookupByLibrary.simpleMessage(
      "Ajoutez une légende pour publier votre vidéo",
    ),
    "infoSelectOrRecord": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez ou enregistrez une vidéo pour commencer",
    ),
    "initializingCamera": MessageLookupByLibrary.simpleMessage(
      "Initialisation de la caméra...",
    ),
    "intent": MessageLookupByLibrary.simpleMessage("Intention"),
    "intentBusiness": MessageLookupByLibrary.simpleMessage("business"),
    "intentEntertainment": MessageLookupByLibrary.simpleMessage(
      "divertissement",
    ),
    "intentFun": MessageLookupByLibrary.simpleMessage("Amusant"),
    "intentInformative": MessageLookupByLibrary.simpleMessage("Informatif"),
    "intentLove": MessageLookupByLibrary.simpleMessage("amour"),
    "intentSerious": MessageLookupByLibrary.simpleMessage("Sérieux"),
    "intentWith": m8,
    "interestFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'expression d\'intérêt",
    ),
    "interestSentWaiting": MessageLookupByLibrary.simpleMessage(
      "Intérêt envoyé ! En attente de réponse...",
    ),
    "interested": MessageLookupByLibrary.simpleMessage("Je suis intéressé(e)"),
    "invalidPhone": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un numéro valide (avec l\'indicatif +)",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Langue"),
    "lightMode": MessageLookupByLibrary.simpleMessage("Mode clair"),
    "listingRemoved": MessageLookupByLibrary.simpleMessage("Annonce supprimée"),
    "loading": MessageLookupByLibrary.simpleMessage("Chargement..."),
    "loadingImage": MessageLookupByLibrary.simpleMessage(
      "Chargement de l\'image...",
    ),
    "locationPermissionNeeded": MessageLookupByLibrary.simpleMessage(
      "📍 L\'accès à la localisation est requis pour trouver des utilisateurs proches",
    ),
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Autorisation de localisation requise pour la correspondance",
    ),
    "login": MessageLookupByLibrary.simpleMessage("CONNEXION"),
    "logout": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir vous déconnecter ?",
    ),
    "logoutDescription": MessageLookupByLibrary.simpleMessage(
      "Quitter l\'application",
    ),
    "lookingForIntentNearby": m9,
    "matchFound": m10,
    "matchHistory": MessageLookupByLibrary.simpleMessage(
      "Historique des matchs",
    ),
    "matchedWith": MessageLookupByLibrary.simpleMessage("Apparié avec"),
    "maximum20Seconds": MessageLookupByLibrary.simpleMessage(
      "Maximum 20 secondes",
    ),
    "mood": m11,
    "moodProfile": MessageLookupByLibrary.simpleMessage("Humeur"),
    "mustBeLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Vous devez être connecté pour commenter",
    ),
    "mutualMatchTitle": MessageLookupByLibrary.simpleMessage(
      "🎉 Match mutuel !",
    ),
    "myBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "Mes badges en vente",
    ),
    "myVideos": MessageLookupByLibrary.simpleMessage("Mes vidéos"),
    "navNow": MessageLookupByLibrary.simpleMessage("Actu"),
    "navProfile": MessageLookupByLibrary.simpleMessage("Profil"),
    "navUpload": MessageLookupByLibrary.simpleMessage("Téléverser"),
    "newCommentNotification": MessageLookupByLibrary.simpleMessage(
      "💬 Nouveau commentaire",
    ),
    "newUsernameHint": MessageLookupByLibrary.simpleMessage(
      "Nouveau nom d\'utilisateur",
    ),
    "noAccountSignUp": MessageLookupByLibrary.simpleMessage(
      "Pas encore de compte ? Inscris-toi",
    ),
    "noBadgesForSale": MessageLookupByLibrary.simpleMessage(
      "Aucun badge en vente",
    ),
    "noCommentsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Partagez vos pensées sur cette vidéo",
    ),
    "noCommentsTitle": MessageLookupByLibrary.simpleMessage(
      "Soyez le premier à commenter !",
    ),
    "noContactInfo": MessageLookupByLibrary.simpleMessage(
      "Pas d\'information de contact",
    ),
    "noImageLoaded": MessageLookupByLibrary.simpleMessage(
      "Aucune image chargée",
    ),
    "noMatchHistory": MessageLookupByLibrary.simpleMessage(
      "Aucun historique de match.",
    ),
    "noMatchesFoundNearby": MessageLookupByLibrary.simpleMessage(
      "Aucune correspondance trouvée à proximité",
    ),
    "noPhoto": MessageLookupByLibrary.simpleMessage("Aucune photo"),
    "noVideoSelected": MessageLookupByLibrary.simpleMessage(
      "Aucune vidéo sélectionnée",
    ),
    "noVideos": MessageLookupByLibrary.simpleMessage("Aucune vidéo disponible"),
    "notConfigured": MessageLookupByLibrary.simpleMessage("Non configuré"),
    "notDefined": MessageLookupByLibrary.simpleMessage("Non défini"),
    "notEnoughDiamonds": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas assez de diamants !",
    ),
    "nowLabel": MessageLookupByLibrary.simpleMessage("Maintenant"),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "other": MessageLookupByLibrary.simpleMessage("Autre"),
    "otpError": MessageLookupByLibrary.simpleMessage(
      "Code incorrect. Veuillez réessayer.",
    ),
    "otpHint": MessageLookupByLibrary.simpleMessage("Code à 6 chiffres"),
    "ownBadgeSellError": MessageLookupByLibrary.simpleMessage(
      "Vous ne pouvez vendre que vos propres badges",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "perfectMatch": MessageLookupByLibrary.simpleMessage(
      "Correspondance parfaite",
    ),
    "permissionRequired": MessageLookupByLibrary.simpleMessage(
      "❌ Autorisation de stockage requise",
    ),
    "phone": MessageLookupByLibrary.simpleMessage("Téléphone"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Numéro de téléphone"),
    "photoSet": MessageLookupByLibrary.simpleMessage("Photo définie"),
    "pleaseAddCaption": MessageLookupByLibrary.simpleMessage(
      "Veuillez ajouter une légende",
    ),
    "priceHint": m12,
    "priceLabel": MessageLookupByLibrary.simpleMessage("Prix en diamants"),
    "profile": MessageLookupByLibrary.simpleMessage("Profil"),
    "profilePhoto": MessageLookupByLibrary.simpleMessage("Photo de profil"),
    "profilePhotoRemoveError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de la suppression",
    ),
    "profilePhotoRemoved": MessageLookupByLibrary.simpleMessage(
      "✅ Photo de profil supprimée",
    ),
    "profilePhotoUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de l\'upload",
    ),
    "profilePhotoUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Photo de profil mise à jour",
    ),
    "profileSection": MessageLookupByLibrary.simpleMessage("Profil"),
    "publishVideoButton": MessageLookupByLibrary.simpleMessage(
      "PUBLIER LA VIDÉO",
    ),
    "rank": MessageLookupByLibrary.simpleMessage("Classement"),
    "recordingError": m13,
    "redo": MessageLookupByLibrary.simpleMessage("Rétablir"),
    "referFriends": MessageLookupByLibrary.simpleMessage("Parraine des amis"),
    "referralDescription": MessageLookupByLibrary.simpleMessage(
      "Gagne 100 diamants pour chaque ami qui rejoint Dadadu avec ton code !",
    ),
    "referralLinkCopied": MessageLookupByLibrary.simpleMessage(
      "Lien de parrainage copié ! 📋",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "repliesCount": m14,
    "reply": MessageLookupByLibrary.simpleMessage("Répondre"),
    "replyToComment": MessageLookupByLibrary.simpleMessage(
      "Répondre au commentaire...",
    ),
    "replyingTo": m15,
    "resetEmailError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de l\'envoi de l\'email",
    ),
    "resetEmailSent": m16,
    "save": MessageLookupByLibrary.simpleMessage("Sauvegarder"),
    "saveButton": MessageLookupByLibrary.simpleMessage("Sauvegarder"),
    "scanningForConnections": MessageLookupByLibrary.simpleMessage(
      "Recherche de connexions...",
    ),
    "searchFailed": MessageLookupByLibrary.simpleMessage(
      "Échec de la recherche",
    ),
    "securitySection": MessageLookupByLibrary.simpleMessage("Sécurité"),
    "selectIntent": MessageLookupByLibrary.simpleMessage(
      "Sélectionne ton intention",
    ),
    "selectionError": m17,
    "sell": MessageLookupByLibrary.simpleMessage("Vendre"),
    "sellBadgeTitle": MessageLookupByLibrary.simpleMessage(
      "Vendre votre badge",
    ),
    "sellButton": MessageLookupByLibrary.simpleMessage("Mettre en vente"),
    "sellCurrentBadgeTitle": MessageLookupByLibrary.simpleMessage(
      "Vendre mon badge actuel",
    ),
    "sendResetEmail": MessageLookupByLibrary.simpleMessage(
      "Envoyer email de réinitialisation",
    ),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "setupDiscover": MessageLookupByLibrary.simpleMessage(
      "Configurer Discover",
    ),
    "share": MessageLookupByLibrary.simpleMessage("Partager"),
    "shareBaseText": m18,
    "shareError": m19,
    "shareFacebookSuffix": MessageLookupByLibrary.simpleMessage(
      "🌟 Rejoins la révolution du contenu authentique !",
    ),
    "shareInstagramSuffix": MessageLookupByLibrary.simpleMessage(
      "📲 #DadaduApp #PasDeLikes #VraiContenu",
    ),
    "shareProfileError": m20,
    "shareProfileSubject": m21,
    "shareProfileText": m22,
    "shareReferralSubject": MessageLookupByLibrary.simpleMessage(
      "Rejoins-moi sur Dadadu !",
    ),
    "shareReferralText": m23,
    "shareSnapchatSuffix": MessageLookupByLibrary.simpleMessage(
      "👻 Plus d\'algorithme, plus de réel !",
    ),
    "shareVideo": MessageLookupByLibrary.simpleMessage(
      "📤 Partager cette vidéo",
    ),
    "shareWhatsAppSuffix": MessageLookupByLibrary.simpleMessage(
      "💎 Télécharge Dadadu et gagne des diamants !",
    ),
    "signUp": MessageLookupByLibrary.simpleMessage("S\'INSCRIRE"),
    "skip": MessageLookupByLibrary.simpleMessage("Ignorer"),
    "socialNetworkLabel": MessageLookupByLibrary.simpleMessage("Réseau social"),
    "sortPopular": MessageLookupByLibrary.simpleMessage("🔥 Populaires"),
    "sortRecent": MessageLookupByLibrary.simpleMessage("🕒 Récents"),
    "sortTrending": MessageLookupByLibrary.simpleMessage("📈 Tendance"),
    "stopRecordingError": m24,
    "theme": MessageLookupByLibrary.simpleMessage("Thème"),
    "trimContinue": MessageLookupByLibrary.simpleMessage(
      "Découper et continuer",
    ),
    "trimTitle": MessageLookupByLibrary.simpleMessage("Découpe ta vidéo"),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "tryChangingIntentOrLater": MessageLookupByLibrary.simpleMessage(
      "Essayez de changer votre intention ou revenez plus tard",
    ),
    "undo": MessageLookupByLibrary.simpleMessage("Annuler"),
    "unknown": MessageLookupByLibrary.simpleMessage("Inconnu"),
    "uploadError": MessageLookupByLibrary.simpleMessage(
      "Erreur de téléchargement",
    ),
    "user": MessageLookupByLibrary.simpleMessage("Utilisateur"),
    "userCommented": m25,
    "userNotLoggedIn": MessageLookupByLibrary.simpleMessage(
      "Utilisateur non connecté",
    ),
    "userProfileNotFound": MessageLookupByLibrary.simpleMessage(
      "Profil utilisateur non trouvé",
    ),
    "userUnknown": MessageLookupByLibrary.simpleMessage("Utilisateur"),
    "username": MessageLookupByLibrary.simpleMessage("Nom d\'utilisateur"),
    "usernameUpdateError": MessageLookupByLibrary.simpleMessage(
      "❌ Erreur lors de la mise à jour",
    ),
    "usernameUpdated": MessageLookupByLibrary.simpleMessage(
      "✅ Nom d\'utilisateur mis à jour",
    ),
    "verify": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "videoIntent": MessageLookupByLibrary.simpleMessage(
      "Intention de la vidéo",
    ),
    "videoLoadingError": m26,
    "videoPublishedSuccessfully": MessageLookupByLibrary.simpleMessage(
      "🎉 Vidéo publiée avec succès !",
    ),
    "videoSaved": MessageLookupByLibrary.simpleMessage(
      "✅ Enregistré dans les téléchargements !",
    ),
    "videos": MessageLookupByLibrary.simpleMessage("Vidéos"),
    "videosOf": MessageLookupByLibrary.simpleMessage("Vidéos de"),
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Bon retour 👽"),
    "welcomeLogin": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "welcomeSignUp": MessageLookupByLibrary.simpleMessage("S\'inscrire"),
    "welcomeToDadadu": MessageLookupByLibrary.simpleMessage(
      "Bienvenue sur Dadadu",
    ),
    "whatsYourVibe": MessageLookupByLibrary.simpleMessage(
      "Quelle est ton humeur aujourd\'hui ?",
    ),
    "yourBadge": MessageLookupByLibrary.simpleMessage("Votre badge"),
  };
}
