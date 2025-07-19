import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:start/screens/home_screen.dart';
import 'package:start/generated/l10n.dart';
import 'package:start/main.dart'; // to access MyApp.setLocale

class ResponsiveSignupScreen extends StatefulWidget {
  const ResponsiveSignupScreen({super.key});

  @override
  State<ResponsiveSignupScreen> createState() => _ResponsiveSignupScreenState();
}

class _ResponsiveSignupScreenState extends State<ResponsiveSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;
  bool _isPhoneMode = false;
  Locale? currentLocale;
  @override
  void didChangeDependencies() {
    currentLocale ??= Localizations.localeOf(context); // set initial locale
    super.didChangeDependencies();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    if (_isPhoneMode) {
      await _signInWithPhone();
    } else {
      await _signUpWithEmail();
    }
  }

  Future<void> _signUpWithEmail() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();

        // Save user info in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'username': _usernameController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        await user.updateDisplayName(_usernameController.text.trim());

        if (!mounted) return;

        setState(() => _isLoading = false);

        // Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Un lien de vérification a été envoyé à votre adresse email. Veuillez vérifier avant de vous connecter.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Optionally, you can redirect to login screen here
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = e.message);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _errorText = "Une erreur est survenue. Réessaye.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithPhone() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _errorText = e.message);
          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) async {
          final code = await _showOtpDialog();
          if (code != null) {
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: code,
            );
            final userCredential = await _auth.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({
                'uid': user.uid,
                'phone': user.phoneNumber,
                'username': _usernameController.text.trim(),
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (!mounted) return;
              setState(() => _isLoading = false);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()));
            }
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      setState(
              () => _errorText = "Erreur lors de la vérification téléphonique.");
    }
  }

  Future<String?> _showOtpDialog() async {
    final otpController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter OTP"),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "6-digit code"),
        ),
        actions: [
          TextButton(
            child: const Text("Submit"),
            onPressed: () =>
                Navigator.of(context).pop(otpController.text.trim()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Image.asset("assets/images/space_background.jpg", fit: BoxFit.cover),
                Container(color: const Color.fromARGB(153, 0, 0, 0)),
                Container(
                  margin: EdgeInsets.all(18.h),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: isPortrait?Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ..._buildSectionA(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait),
                          ..._buildSectionB(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait),

                        ],
                      ) : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              ..._buildSectionA(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait),
                            ],
                          ),
                          Column(
                            children: [
                              ..._buildSectionB(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _buildLanguageDropdown(S s) {
    return DropdownButton<Locale>(
      dropdownColor: Colors.grey[900],
      value: currentLocale,
      onChanged: (Locale? newLocale)async {
        if (newLocale != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('locale', newLocale.languageCode);
          if (mounted) {
            MyApp.setLocale(context, newLocale);
          }

          setState(() => currentLocale = newLocale);
        }
      },
      iconEnabledColor: Colors.white,
      items: S.delegate.supportedLocales.map((locale) {
        final flag = _localeToFlag(locale.languageCode);
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                _localeDisplayName(locale.languageCode),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _localeDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return code.toUpperCase();
    }
  }



  String _localeToFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      default:
        return '🇺🇸 (';
    }
  }



  Widget _authToggle(S s) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => setState(() => _isPhoneMode = false),
          child: Text(
            s.email,
            style: TextStyle(
              color: !_isPhoneMode ? Colors.white : Colors.white54,
            ),
          ),
        ),
        const Text("|", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => setState(() => _isPhoneMode = true),
          child: Text(
            s.phone,
            style: TextStyle(
              color: _isPhoneMode ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ],
    );
  }

  // THIS WIDGET IS REWRITTEN MULTIPLE TIMES
  // MARKET TO BE REFACTORED LATER

  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPortrait = true
  }) {
    return Container(
      width: isPortrait ? 0.9.sw : 0.35.sw,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white70),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }

  List<Widget> _buildSectionA(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
      Text(
        s.createYourDadaduID,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 12),
      _authToggle(s),
      const SizedBox(height: 14),
    ];
  }

  List<Widget> _buildSectionB(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
      _glassInput(
          controller: _usernameController,
          hint: s.username,
          icon: Icons.person_outline,
          isPortrait: isPortrait
      ),
      const SizedBox(height: 14),
      _isPhoneMode
          ? _glassInput(
          controller: _phoneController,
          hint: s.phoneNumber,
          icon: Icons.phone,
          isPortrait: isPortrait)
          : _glassInput(
          controller: _emailController,
          hint: s.email,
          icon: Icons.email_outlined,
          isPortrait: isPortrait),
      const SizedBox(height: 14),
      if (!_isPhoneMode)
        _glassInput(
            controller: _passwordController,
            hint: s.password,
            icon: Icons.lock_outline,
            obscure: true,
            isPortrait: isPortrait),
      const SizedBox(height: 24),
      if (_errorText != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _errorText!,
            style: const TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      SizedBox(
        width: isPortrait ? 0.9.sw : 0.35.sw,
        child: FilledButton.icon(
          onPressed: _isLoading ? null : _signUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.tealAccent[400],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 32),
          ),
          icon: _isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
          )
              : const Icon(Icons.person_add_alt_1),
          label: Text(_isLoading ? s.creating : s.signUp),
        ),
      ),
      const SizedBox(height: 14),
      _buildLanguageDropdown(s),
    ];
  }

}