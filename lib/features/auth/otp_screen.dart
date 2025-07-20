import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:start/screens/home_screen.dart';
import 'package:start/generated/l10n.dart'; // <-- Adjust if your localization file is elsewhere

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({required this.verificationId, Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  Future<void> _verifyOTP() async {
    setState(() => _loading = true);
    final smsCode = _otpController.text.trim();

    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).otpError)),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(s.enterOtpMessage),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: s.otpHint,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _verifyOTP,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(s.verify),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
