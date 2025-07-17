// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get createYourDadaduID => 'Crée ton ID Dadadu 🚀';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Téléphone';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get password => 'Mot de passe';

  @override
  String get signUp => 'S\'INSCRIRE';

  @override
  String get creating => 'Création en cours...';

  @override
  String get welcomeBack => 'Bon retour 👽';

  @override
  String get login => 'CONNEXION';

  @override
  String get loading => 'Chargement...';

  @override
  String get noAccountSignUp => 'Pas encore de compte ? Inscris-toi';

  @override
  String get invalidPhone =>
      'Veuillez entrer un numéro valide (avec l\'indicatif +)';

  @override
  String get genericError => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get welcomeToDadadu => 'Bienvenue sur Dadadu';

  @override
  String get welcomeSignUp => 'S\'inscrire';

  @override
  String get welcomeLogin => 'Se connecter';

  @override
  String get navNow => 'Actu';

  @override
  String get navUpload => 'Téléverser';

  @override
  String get navProfile => 'Profil';

  @override
  String get feedPersonalizing => 'Personnalisation du feed...';

  @override
  String get feedAnalyzingPreferences => 'Analyse de vos préférences';

  @override
  String get noVideos => 'Aucune vidéo disponible';

  @override
  String get followCreators => 'Suivez des créateurs pour voir leur contenu';

  @override
  String get refresh => 'Actualiser';

  @override
  String get nowLabel => 'Maintenant';

  @override
  String get discover => 'Découvrir';

  @override
  String get noMatchesFoundNearby =>
      'Aucune correspondance trouvée à proximité';

  @override
  String get tryChangingIntentOrLater =>
      'Essayez de changer votre intention ou revenez plus tard';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get scanningForConnections => 'Recherche de connexions...';

  @override
  String lookingForIntentNearby(Object intent) {
    return 'Recherche de $intent à proximité';
  }

  @override
  String get cancelSearch => 'Annuler la recherche';

  @override
  String get whatsYourVibe => 'Quelle est ton humeur aujourd\'hui ?';

  @override
  String get locationPermissionNeeded =>
      '📍 L\'accès à la localisation est requis pour trouver des utilisateurs proches';

  @override
  String get locationPermissionRequired =>
      'Autorisation de localisation requise pour la correspondance';

  @override
  String get interestSentWaiting => 'Intérêt envoyé ! En attente de réponse...';

  @override
  String get mutualMatchTitle => '🎉 Match mutuel !';

  @override
  String get contactLabel => 'Contact pour les matchs';

  @override
  String get noContactInfo => 'Pas d\'information de contact';

  @override
  String get greatButton => 'Génial !';

  @override
  String get interestFailed => 'Échec de l\'expression d\'intérêt';

  @override
  String get searchFailed => 'Échec de la recherche';

  @override
  String matchFound(Object emoji) {
    return '$emoji Correspondance trouvée !';
  }

  @override
  String get perfectMatch => 'Correspondance parfaite';

  @override
  String get greatMatch => 'Bonne correspondance';

  @override
  String get goodMatch => 'Correspondance correcte';

  @override
  String mood(Object emoji, Object mood) {
    return 'Humeur';
  }

  @override
  String away(Object distance) {
    return '${distance}m de distance';
  }

  @override
  String diamonds(Object count) {
    return 'Diamants';
  }

  @override
  String get skip => 'Ignorer';

  @override
  String get interested => 'Je suis intéressé(e)';

  @override
  String get enterOtpMessage => 'Entrez le code envoyé à votre téléphone';

  @override
  String get otpHint => 'Code à 6 chiffres';

  @override
  String get verify => 'Vérifier';

  @override
  String get otpError => 'Code incorrect. Veuillez réessayer.';

  @override
  String get cropImage => 'Rogner l\'image';

  @override
  String get error => 'Erreur';

  @override
  String get cropFailed => 'Échec du rognage de l\'image';

  @override
  String get ok => 'OK';

  @override
  String get noImageLoaded => 'Aucune image chargée';

  @override
  String get loadingImage => 'Chargement de l\'image...';

  @override
  String get imageReady => 'Image prête !';

  @override
  String get cropping => 'Rognage...';

  @override
  String get undo => 'Annuler';

  @override
  String get redo => 'Rétablir';

  @override
  String get cropAndSave => 'Rogner et enregistrer';

  @override
  String get user => 'Utilisateur';

  @override
  String get profile => 'Profil';

  @override
  String get moodProfile => 'Humeur';

  @override
  String get howBadgesWork => 'Comment fonctionnent les badges';

  @override
  String get followers => 'Abonnés';

  @override
  String get following => 'Abonnements';

  @override
  String get rank => 'Classement';

  @override
  String get noMatchHistory => 'Aucun historique de match.';

  @override
  String get matchHistory => 'Historique des matchs';

  @override
  String get matchedWith => 'Apparié avec';

  @override
  String get unknown => 'Inconnu';

  @override
  String get intent => 'Intention';

  @override
  String get follow => 'Suivre';

  @override
  String get followingStatus => 'Abonné';

  @override
  String get videos => 'Vidéos';

  @override
  String get diamondsProfile => 'Diamants';

  @override
  String get myVideos => 'Mes vidéos';

  @override
  String get videosOf => 'Vidéos de';

  @override
  String get badgeMarketplace => 'Marché des badges';

  @override
  String get referFriends => 'Parraine des amis';

  @override
  String get referralDescription =>
      'Gagne 100 diamants pour chaque ami qui rejoint Dadadu avec ton code !';

  @override
  String get copyLink => 'Copier le lien';

  @override
  String get share => 'Partager';

  @override
  String get changeUsername => 'Changer le nom d\'utilisateur';

  @override
  String get newUsernameHint => 'Nouveau nom d\'utilisateur';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Sauvegarder';

  @override
  String get referralLinkCopied => 'Lien de parrainage copié ! 📋';

  @override
  String shareProfileText(Object profileUrl, Object username) {
    return '🎬 Découvre le profil de $username sur Dadadu !\nUne app de vidéos courtes authentiques sans likes ni vues.\n$profileUrl\n\n#Dadadu #Profile';
  }

  @override
  String shareProfileSubject(Object username) {
    return 'Profil Dadadu de $username';
  }

  @override
  String shareProfileError(Object error) {
    return 'Erreur lors du partage: $error';
  }

  @override
  String shareReferralText(Object referralLink) {
    return '🎬 Rejoins-moi sur Dadadu ! Une app de vidéos courtes sans likes, juste de l\'authenticité locale. Utilise mon code de parrainage pour gagner 100 💎 : $referralLink\n\n#Dadadu #Authentique #PasDeVues';
  }

  @override
  String get shareReferralSubject => 'Rejoins-moi sur Dadadu !';

  @override
  String get listingRemoved => 'Annonce supprimée';

  @override
  String errorRemovingListing(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get notEnoughDiamonds => 'Vous n\'avez pas assez de diamants !';

  @override
  String get badgePurchased => 'Badge acheté avec succès !';

  @override
  String badgePurchaseError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get badgeListed => 'Badge mis en vente avec succès !';

  @override
  String badgeListingError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get sellBadgeTitle => 'Vendre votre badge';

  @override
  String get priceLabel => 'Prix en diamants';

  @override
  String priceHint(Object price) {
    return 'Prix suggéré: $price 💎';
  }

  @override
  String get descriptionLabel => 'Description (optionnelle)';

  @override
  String get buy => 'Acheter';

  @override
  String get sell => 'Vendre';

  @override
  String get sellCurrentBadgeTitle => 'Vendre mon badge actuel';

  @override
  String get sellButton => 'Mettre en vente';

  @override
  String get ownBadgeSellError =>
      'Vous ne pouvez vendre que vos propres badges';

  @override
  String get myBadgesForSale => 'Mes badges en vente';

  @override
  String get noBadgesForSale => 'Aucun badge en vente';

  @override
  String buyForDiamonds(Object diamonds) {
    return 'Acheter $diamonds 💎';
  }

  @override
  String get yourBadge => 'Votre badge';

  @override
  String get badgeSystemTitle => '🏆 SYSTÈME DE BADGES DADADU';

  @override
  String get badgeLeafTitle => 'FEUILLE (0–9 999 diamants)';

  @override
  String get badgeLeafDesc => 'Niveau de départ pour les nouveaux utilisateurs';

  @override
  String get badgeThreeleafTitle => 'TREFLE (10K–999K)';

  @override
  String get badgeThreeleafDesc => 'Membre actif de la communauté';

  @override
  String get badgeFiveleafTitle => 'CINQFEUILLES (1M–9,9M)';

  @override
  String get badgeFiveleafDesc => 'Statut de créateur populaire';

  @override
  String get badgeDadalordTitle => 'DADALORD (10M+)';

  @override
  String get badgeDadalordDesc =>
      'Statut élite d\'une valeur de \\\$10 000+ avec +2% par million de diamants';

  @override
  String get badgeNote =>
      '📈 Les badges plus élevés = plus de prestige + valeur sur le marketplace';

  @override
  String get gotIt => 'Compris';

  @override
  String get profilePhotoRemoved => '✅ Photo de profil supprimée';

  @override
  String get profilePhotoRemoveError => '❌ Erreur lors de la suppression';

  @override
  String get profilePhotoUpdated => '✅ Photo de profil mise à jour';

  @override
  String get profilePhotoUpdateError => '❌ Erreur lors de l\'upload';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get userUnknown => 'Utilisateur';

  @override
  String get profileSection => 'Profil';

  @override
  String get setupDiscover => 'Configurer Discover';

  @override
  String intentWith(Object intent) {
    return 'Intent : $intent';
  }

  @override
  String get notConfigured => 'Non configuré';

  @override
  String get notDefined => 'Non défini';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get photoSet => 'Photo définie';

  @override
  String get noPhoto => 'Aucune photo';

  @override
  String get generalSection => 'Général';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get securitySection => 'Sécurité';

  @override
  String get changePassword => 'Changer mot de passe';

  @override
  String get sendResetEmail => 'Envoyer email de réinitialisation';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutDescription => 'Quitter l\'application';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get discoverConfigUpdated => '🎯 Configuration Discover mise à jour';

  @override
  String get discoverConfigError => '❌ Erreur lors de la sauvegarde';

  @override
  String get discoverConfigTitle => 'Configuration Discover';

  @override
  String get selectIntent => 'Sélectionne ton intention';

  @override
  String get socialNetworkLabel => 'Réseau social';

  @override
  String get identifierHint => 'Ton identifiant';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get intentLove => 'amour';

  @override
  String get intentBusiness => 'business';

  @override
  String get intentEntertainment => 'divertissement';

  @override
  String resetEmailSent(Object email) {
    return '📧 Email de réinitialisation envoyé à $email';
  }

  @override
  String get resetEmailError => '❌ Erreur lors de l\'envoi de l\'email';

  @override
  String get imageSelectionError => '❌ Erreur lors de la sélection de l\'image';

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get delete => 'Supprimer';

  @override
  String get usernameUpdated => '✅ Nom d\'utilisateur mis à jour';

  @override
  String get usernameUpdateError => '❌ Erreur lors de la mise à jour';

  @override
  String get changeUsernameTitle => 'Nouveau nom d\'utilisateur';

  @override
  String get changeUsernameHint => 'Entrez votre nouveau nom';

  @override
  String get confirm => 'Valider';

  @override
  String get trimTitle => 'Découpe ta vidéo';

  @override
  String get trimContinue => 'Découper et continuer';

  @override
  String get language => 'Langue';

  @override
  String shareBaseText(Object caption, Object username) {
    return '🎬 Regarde cette vidéo sur Dadadu !\n\"$caption\"\nPar @$username\n\n📱 Appli vidéo authentique sans likes ni vues\n#Dadadu #Authentique #Local';
  }

  @override
  String get shareWhatsAppSuffix =>
      '💎 Télécharge Dadadu et gagne des diamants !';

  @override
  String get shareInstagramSuffix => '📲 #DadaduApp #PasDeLikes #VraiContenu';

  @override
  String get shareFacebookSuffix =>
      '🌟 Rejoins la révolution du contenu authentique !';

  @override
  String get shareSnapchatSuffix => '👻 Plus d\'algorithme, plus de réel !';

  @override
  String get permissionRequired => '❌ Autorisation de stockage requise';

  @override
  String get downloading => '📥 Téléchargement...';

  @override
  String get videoSaved => '✅ Enregistré dans les téléchargements !';

  @override
  String errorSavingVideo(Object error) {
    return '❌ Erreur lors de l\'enregistrement : $error';
  }

  @override
  String get shareVideo => '📤 Partager cette vidéo';

  @override
  String get download => 'Télécharger';

  @override
  String get other => 'Autre';

  @override
  String shareError(Object error) {
    return '❌ Erreur de partage : $error';
  }

  @override
  String replyingTo(Object username) {
    return 'Réponse à $username';
  }

  @override
  String get replyToComment => 'Répondre au commentaire...';

  @override
  String get addComment => 'Ajouter un commentaire...';

  @override
  String get creator => 'CRÉATEUR';

  @override
  String get reply => 'Répondre';

  @override
  String repliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'réponses',
      one: 'réponse',
    );
    return '$count $_temp0';
  }

  @override
  String get noCommentsTitle => 'Soyez le premier à commenter !';

  @override
  String get noCommentsSubtitle => 'Partagez vos pensées sur cette vidéo';

  @override
  String get sortRecent => '🕒 Récents';

  @override
  String get sortPopular => '🔥 Populaires';

  @override
  String get sortTrending => '📈 Tendance';

  @override
  String get commentsTitle => '💬 Commentaires';

  @override
  String commentsCount(Object count) {
    return '$count commentaires';
  }

  @override
  String get mustBeLoggedIn => 'Vous devez être connecté pour commenter';

  @override
  String get commentPosted => '💬 Commentaire publié !';

  @override
  String get commentError => 'Erreur lors de l\'envoi';

  @override
  String get newCommentNotification => '💬 Nouveau commentaire';

  @override
  String userCommented(Object username) {
    return '$username a commenté votre vidéo';
  }

  @override
  String get createVideoTitle => 'Créer une vidéo';

  @override
  String get createDadaduVideo => 'Créez votre vidéo Dadadu';

  @override
  String get maximum20Seconds => 'Maximum 20 secondes';

  @override
  String get captionHint =>
      'Décrivez votre vidéo...\nQue voulez-vous partager ?';

  @override
  String get publishVideoButton => 'PUBLIER LA VIDÉO';

  @override
  String get infoAddCaption => 'Ajoutez une légende pour publier votre vidéo';

  @override
  String get infoSelectOrRecord =>
      'Sélectionnez ou enregistrez une vidéo pour commencer';

  @override
  String get videoIntent => 'Intention de la vidéo';

  @override
  String get intentFun => 'Amusant';

  @override
  String get intentSerious => 'Sérieux';

  @override
  String get intentInformative => 'Informatif';

  @override
  String get close => 'Fermer';

  @override
  String get initializingCamera => 'Initialisation de la caméra...';

  @override
  String get noVideoSelected => 'Aucune vidéo sélectionnée';

  @override
  String get pleaseAddCaption => 'Veuillez ajouter une légende';

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get userProfileNotFound => 'Profil utilisateur non trouvé';

  @override
  String get videoPublishedSuccessfully => '🎉 Vidéo publiée avec succès !';

  @override
  String get uploadError => 'Erreur de téléchargement';

  @override
  String stopRecordingError(Object error) {
    return 'Erreur lors de l\'arrêt de l\'enregistrement : $error';
  }

  @override
  String recordingError(Object error) {
    return 'Erreur d\'enregistrement : $error';
  }

  @override
  String selectionError(Object error) {
    return 'Erreur de sélection : $error';
  }

  @override
  String videoLoadingError(Object error) {
    return 'Erreur de chargement vidéo : $error';
  }
}
