import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../widgets/neon_button.dart';
import 'package:start/generated/l10n.dart'; // Import your localization

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = S.of(context); // Localization shortcut

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 🌌 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/space_background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🌍 Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🪐 Logo
                  SizedBox(
                    width: size.width * 0.45,
                    child: Image.asset(
                      'assets/icons/logo.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    s.welcomeToDadadu, // Localized text
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 🔐 Signup button (blue neon)
                  NeonButton(
                    text: s.welcomeSignUp,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🔑 Login button (yellow neon)
                  NeonButton(
                    text: s.welcomeLogin,
                    glowColor: Colors.amberAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
