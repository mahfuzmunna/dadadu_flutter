import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:start/features/auth/login_screen.dart';
import 'package:start/features/auth/otp_screen.dart';
import 'package:start/features/auth/responsive_login_screen.dart';
import 'package:start/features/auth/responsive_signup_screen.dart';
import 'package:start/screens/home_screen.dart';
import '../../features/auth/signup_screen.dart';
import 'package:start/generated/l10n.dart';

class ResponsiveResetPasswordScreen extends StatefulWidget {
  const ResponsiveResetPasswordScreen({super.key});

  @override
  State<ResponsiveResetPasswordScreen> createState() => _ResponsiveResetPasswordScreenState();
}

enum AuthMethod { email, phone }

class _ResponsiveResetPasswordScreenState extends State<ResponsiveResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthMethod _authMethod = AuthMethod.email;
  bool _isLoading = false;
  String? _errorText;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {

      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to ${_emailController.text.trim()}'))
      );

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
                      child: isPortrait ? Column(
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
        s.resetPassword,
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
      const SizedBox(height: 20),
    ];
  }
  List<Widget> _buildSectionB(BuildContext context, Size size, S s, ColorScheme colorScheme, bool isPortrait) {
    return [
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
          onPressed: _isLoading ? null : _resetPassword,
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
              : const Icon(Icons.lock_reset),
          label: Text(_isLoading ? s.loading : 'Reset Password'),
        ),
      ),

      const SizedBox(height: 16),

      SizedBox(
        width: isPortrait ? 0.9.sw : 0.35.sw,
        child: TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResponsiveLoginScreen()),
          ),
          child: Text(
            'Back to Login',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
      SizedBox(
        width: isPortrait ? 0.9.sw : 0.35.sw,
        child: TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResponsiveSignupScreen()),
          ),
          child: Text(
            'Sign Up',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    ];
  }
}
