import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:start/auth/otp_screen.dart';
import 'package:start/auth/reset_password_screen.dart';
import 'package:start/auth/responsive_reset_password_screen.dart';
import 'package:start/auth/responsive_signup_screen.dart';
import 'package:start/screens/home_screen.dart';
import 'signup_screen.dart';
import 'package:start/generated/l10n.dart';

class ResponsiveLoginScreen extends StatefulWidget {
  const ResponsiveLoginScreen({super.key});

  @override
  State<ResponsiveLoginScreen> createState() => _ResponsiveLoginScreenState();
}

enum AuthMethod { email, phone }

class _ResponsiveLoginScreenState extends State<ResponsiveLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthMethod _authMethod = AuthMethod.email;
  bool _isLoading = false;
  String? _errorText;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      if (_authMethod == AuthMethod.phone) {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty || !phone.startsWith('+')) {
          setState(() {
            _errorText = S.of(context).invalidPhone;
            _isLoading = false;
          });
          return;
        }

        await _auth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _auth.signInWithCredential(credential);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _errorText = e.message;
              _isLoading = false;
            });
          },
          codeSent: (verificationId, resendToken) {
            setState(() => _isLoading = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(verificationId: verificationId),
              ),
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorText = e.message);
    } catch (_) {
      setState(() => _errorText = S.of(context).genericError);
    } finally {
      setState(() => _isLoading = false);
    }
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
                Container(color: const Color.fromARGB(170, 0, 0, 0)),
                Container(
                  margin: EdgeInsets.all(18.h),
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: isPortrait? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ..._buildSectionA(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait),
                          ..._buildSectionB(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait)
                        ],
                      ) :Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                               ..._buildSectionA(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait)
                            ],
                          ),
                          Column(
                            children: [
                              ..._buildSectionB(context, MediaQuery.of(context).size, s, Theme.of(context).colorScheme, isPortrait)
                            ],
                          )
                        ]
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

  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPortrait = true
  }) {
    return Container(
      width: isPortrait ?  0.9.sw : 0.35.sw,
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
        s.welcomeBack,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 20),
      ToggleButtons(
        isSelected: [
          _authMethod == AuthMethod.email,
          _authMethod == AuthMethod.phone,
        ],
        borderRadius: BorderRadius.circular(20),
        onPressed: (index) {
          setState(() {
            _authMethod = AuthMethod.values[index];
          });
        },
        selectedColor: Colors.white,
        color: Colors.white54,
        fillColor: Colors.white12,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(s.email),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(s.phone),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSectionB(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
      const SizedBox(height: 20),
      _authMethod == AuthMethod.email
          ? _glassInput(
          controller: _emailController,
          hint: s.email,
          icon: Icons.email_outlined,
          isPortrait: isPortrait
      )
          : _glassInput(
          controller: _phoneController,
          hint: s.phoneNumber,
          icon: Icons.phone,
          isPortrait: isPortrait
      ),
      const SizedBox(height: 16),
      if (_authMethod == AuthMethod.email)
        _glassInput(
            controller: _passwordController,
            hint: s.password,
            obscure: true,
            icon: Icons.lock_outline,
            isPortrait: isPortrait
        ),
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
      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResponsiveResetPasswordScreen()),
        ),
        child: Text(
          s.forgotPassword,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
      SizedBox(
        width: isPortrait? 0.9.sw : 0.35.sw,
        child: FilledButton.icon(
          onPressed: _isLoading ? null : _signIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
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
              color: Colors.white,
            ),
          )
              : const Icon(Icons.login),
          label: Text(_isLoading ? s.loading : s.login),
        ),
      ),

      const SizedBox(height: 16),

      TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResponsiveSignupScreen()),
        ),
        child: Text(
          s.noAccountSignUp,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    ];
  }
}