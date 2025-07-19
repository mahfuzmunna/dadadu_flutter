import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/generated/l10n.dart';
import 'package:start/main.dart';

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/screens/image_crop.dart';
import 'dart:io';
import '../auth/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  // ignore: non_constant_identifier_names
  const SettingsScreen(
      // ignore: non_constant_identifier_names
      {super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _isDarkMode = true;
  bool _isLoading = false;
  Map<String, dynamic> _userData = {};
  Locale? _locale;

  Future<void> _changeLanguage(
      BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', languageCode);
    setState(() {
      _locale = Locale(languageCode);
    });
    if (mounted) {
      // ignore: use_build_context_synchronously
      MyApp.setLocale(context, _locale!);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data()!;
        });
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Future<void> _loadThemePreference() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (mounted) {
  //     // setState(() {
  //     //   _isDarkMode = prefs.getBool('isDarkMode') ?? true;
  //     // });
  //   }
  // }

  Future<void> _toggleTheme(bool isDarkMode, ThemeData theme) async {
    if (isDarkMode) {
      AdaptiveTheme.of(context).setLight();
    } else {
      AdaptiveTheme.of(context).setDark();
    }
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _isDarkMode = !_isDarkMode;
    // });
    // await prefs.setBool('isDarkMode', _isDarkMode);
    ;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isDarkMode ? "🌙 Mode sombre activé" : "☀️ Mode clair activé",
            style: TextStyle(color: !isDarkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: !isDarkMode ? Colors.grey[800] : Colors.grey[200],
        ),
      );
    }
  }

  Future<void> _changeUsername(ThemeData theme) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    String? newUsername;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          S.of(context).changeUsernameTitle,
          style: TextStyle(color: theme.primaryColor),
        ),
        content: TextField(
          onChanged: (value) => newUsername = value,
          style: TextStyle(color: theme.primaryColor),
          decoration: InputDecoration(
            hintText: S.of(context).changeUsernameHint,
            hintStyle: theme.inputDecorationTheme.hintStyle,
            enabledBorder: theme.inputDecorationTheme.enabledBorder,
            focusedBorder: theme.inputDecorationTheme.focusedBorder,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel,
                style: TextStyle(color: theme.canvasColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newUsername != null && newUsername!.trim().isNotEmpty) {
                Navigator.pop(context);
                await _updateUsername(newUsername!.trim());
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
            child: Text(S.of(context).confirm,
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateUsername(String username) async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': username,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).usernameUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).usernameUpdateError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeProfilePicture(ThemeData theme) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.inputDecorationTheme.enabledBorder!.borderSide.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).profilePhoto,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: S.of(context).camera,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  theme: theme,
                ),
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: S.of(context).gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  theme: theme,
                ),
                if (_userData['photoUrl'] != null)
                  _buildPhotoOption(
                    icon: Icons.delete,
                    label: S.of(context).delete,
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfilePicture();
                    },
                    theme: theme,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required ThemeData theme,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.amberAccent, width: 1),
            ),
            child: Icon(icon, color: Colors.amberAccent, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile =
          await picker.pickImage(source: source, imageQuality: 80);

      if (pickedFile != null) {
        final cropped = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CropSample(imageFile: pickedFile),
          ),
        );
        if (cropped != null && cropped is Uint8List) {
          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final croppedFile = await File(filePath).writeAsBytes(cropped);
          await _uploadProfilePicture(croppedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).imageSelectionError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final ref =
          FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).profilePhotoUpdated)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoUpdateError)),
        );
      }
    }
  }

  Future<void> _removeProfilePicture() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Delete from Storage
      try {
        await FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$uid.jpg')
            .delete();
      } catch (e) {
        // Ignore if file doesn't exist
      }

      // Delete from Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoRemoved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).profilePhotoRemoveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).resetEmailSent(user.email!)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).resetEmailError)),
        );
      }
    }
  }

  Future<void> _configureMatchingData(ThemeData theme) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    String? selectedIntent = _userData['intent'];
    String? contactKey;
    String? contactValue;

    // Récupérer contact existant
    if (_userData['contact'] != null) {
      final contact = _userData['contact'] as Map<String, dynamic>;
      if (contact.isNotEmpty) {
        contactKey = contact.keys.first;
        contactValue = contact[contactKey];
      }
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.enabledBorder!
                            .borderSide.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).discoverConfigTitle,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).selectIntent,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: ['love', 'business', 'entertainment']
                        .map((intent) => ChoiceChip(
                            label: Text(
                              intent == 'love'
                                  ? S.of(context).intentLove
                                  : intent == 'business'
                                      ? S.of(context).intentBusiness
                                      : S.of(context).intentEntertainment,
                            ),
                            selected: selectedIntent == intent,
                            onSelected: (_) =>
                                setState(() => selectedIntent = intent),
                            selectedColor: Colors.amberAccent,
                            backgroundColor: theme.highlightColor))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    S.of(context).contactLabel,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: theme.focusColor,
                    decoration: InputDecoration(
                      labelText: S.of(context).socialNetworkLabel,
                      labelStyle: TextStyle(
                          color: theme.inputDecorationTheme.hintStyle!.color),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: theme.inputDecorationTheme.enabledBorder!
                                .borderSide.color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amberAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: contactKey,
                    items: [
                      DropdownMenuItem(
                        value: 'snapchat',
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 12, color: Colors.black),
                            ),
                            const SizedBox(width: 8),
                            Text('Snapchat',
                                style: TextStyle(color: theme.primaryColor)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'whatsapp',
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.phone,
                                  size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text('WhatsApp',
                                style: TextStyle(color: theme.primaryColor)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'instagram',
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.photo_camera,
                                  size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text('Instagram',
                                style: TextStyle(color: theme.primaryColor)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => contactKey = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (val) => contactValue = val,
                    controller: TextEditingController(text: contactValue),
                    style: TextStyle(color: theme.primaryColor),
                    decoration: InputDecoration(
                      hintText: S.of(context).identifierHint,
                      hintStyle: TextStyle(color: theme.splashColor),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: theme.inputDecorationTheme.enabledBorder!
                                .borderSide.color),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.amberAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedIntent != null &&
                            contactKey != null &&
                            contactValue != null &&
                            contactValue!.trim().isNotEmpty) {
                          Navigator.pop(context);
                          await _saveMatchingConfiguration(
                              selectedIntent!, contactKey!, contactValue!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        S.of(context).saveButton,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _saveMatchingConfiguration(
      String intent, String contactKey, String contactValue) async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final pos = await Geolocator.getCurrentPosition();
      final placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final country = placemarks.first.country ?? 'Unknown';

      final data = {
        'intent': intent,
        'lat': pos.latitude,
        'lng': pos.longitude,
        'country': country,
        'contact': {contactKey: contactValue},
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      await _loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).discoverConfigUpdated), // Localized
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).discoverConfigError), // Localized
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut(BuildContext context, ThemeData theme) async {




    await showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text(
          S.of(context).logout, // "Logout" / "Se déconnecter" / "Abmelden"
          style: TextStyle(color: theme.primaryColor),
        ),
        content: Text(
          S.of(context).logoutConfirm, // "Are you sure you want to logout?"
          style: TextStyle(color: theme.shadowColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel, // "Cancel"
              style: TextStyle(
                color: theme.inputDecorationTheme.hintStyle?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              S.of(context).logout, // Use the same localized logout text
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height / 3.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            ListTile(
              title: const Text("🇬🇧 English"),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage(context, 'en');
              },
            ),
            ListTile(
              title: const Text("🇫🇷 Français"),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage(context, 'fr');
              },
            ),
            ListTile(
              title: const Text("🇩🇪 Deutsch"),
              onTap: () {
                Navigator.pop(context);
                _changeLanguage(context, 'de');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final bgColor = _isDarkMode ? Colors.black : Colors.white;
    // final textColor = _isDarkMode ? Colors.white : Colors.black;
    final locale = Localizations.localeOf(context);
    return ValueListenableBuilder(
      valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
      builder: (context, mode, _) {
        final isDarkMode = mode == AdaptiveThemeMode.dark;
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(S.of(context).settingsTitle,
                style: TextStyle(color: theme.primaryColor)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.primaryColor),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.amberAccent),
                )
              : ListView(
                  children: [
                    // En-tête profil
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.hintColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey.shade300,
                            child: ClipOval(
                              child: _userData['photoUrl'] != null &&
                                      _userData['photoUrl'].isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: _userData['photoUrl'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error,
                                              size: 40,
                                              color: Colors.redAccent),
                                    )
                                  : const Icon(Icons.person,
                                      size: 50, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData['username'] ??
                                      S.of(context).userUnknown,
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  FirebaseAuth.instance.currentUser?.email ??
                                      FirebaseAuth
                                          .instance.currentUser?.phoneNumber ??
                                      '',
                                  style: TextStyle(
                                    color: theme.canvasColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle(S.of(context).profileSection, theme),
                    _buildTile(
                      icon: Icons.settings_input_antenna,
                      title: S.of(context).setupDiscover,
                      subtitle: _userData['intent'] != null
                          ? S.of(context).intentWith(_userData['intent'])
                          : S.of(context).notConfigured,
                      onTap: () => _configureMatchingData(theme),
                      theme: theme,
                    ),
                    _buildTile(
                      icon: Icons.person_outline,
                      title: S.of(context).username,
                      subtitle:
                          _userData['username'] ?? S.of(context).notDefined,
                      onTap: () => _changeUsername(theme),
                      theme: theme,
                    ),
                    _buildTile(
                      icon: Icons.image_outlined,
                      title: S.of(context).profilePhoto,
                      subtitle: _userData['photoUrl'] != null
                          ? S.of(context).photoSet
                          : S.of(context).noPhoto,
                      onTap: () => _changeProfilePicture(theme),
                      theme: theme,
                    ),

                    _buildSectionTitle(S.of(context).generalSection, theme),
                    _buildTile(
                      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      title: S.of(context).theme,
                      subtitle: isDarkMode
                          ? S.of(context).darkMode
                          : S.of(context).lightMode,
                      onTap: () => _toggleTheme(isDarkMode, theme),
                      theme: theme,
                    ),
                    _buildTile(
                      icon: Icons.language,
                      title: S.of(context).language,
                      subtitle: locale.languageCode == 'de'
                          ? 'Deutsch'
                          : locale.languageCode == 'fr'
                              ? 'Français'
                              : 'English',
                      onTap: () => _showLanguagePicker(context, theme),
                      theme: theme,
                    ),

                    _buildSectionTitle(S.of(context).securitySection, theme),
                    _buildTile(
                      icon: Icons.lock_outline,
                      title: S.of(context).changePassword,
                      subtitle: S.of(context).sendResetEmail,
                      onTap: _changePassword,
                      theme: theme,
                    ),
                    _buildTile(
                      icon: Icons.logout,
                      title: S.of(context).logout,
                      subtitle: S.of(context).logoutDescription,
                      onTap: () => _signOut(context, theme),
                      isDestructive: true,
                      theme: theme,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required ThemeData theme,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    // final tileColor = _isDarkMode ? Colors.grey[900] : Colors.grey[50];
    final iconColor = isDestructive ? Colors.red : Colors.amberAccent;
    final titleColor = isDestructive ? Colors.red : (theme.primaryColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: theme.canvasColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.splashColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: theme.inputDecorationTheme.hintStyle!.color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
