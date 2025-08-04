// lib/features/auth/presentation/pages/quick_sign_up_page.dart

import 'package:dadadu_app/core/util/check_for_deferred.dart';
import 'package:dadadu_app/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';

class QuickSignUpPage extends StatefulWidget {
  const QuickSignUpPage({super.key});

  @override
  State<QuickSignUpPage> createState() => _QuickSignUpPageState();
}

class _QuickSignUpPageState extends State<QuickSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(); // New controller for phone
  String? _capturedReferralId;

  @override
  void initState() {
    super.initState();
    _checkForReferral();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkForReferral() async {
    final referralId = await checkForDeferredReferral();
    if (mounted) {
      setState(() {
        _capturedReferralId = referralId;
      });
    }
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final String emailUsername = _emailController.text.trim().split('@')[0];
      final test = emailUsername;
      context.read<AuthBloc>().add(AuthQuickSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: emailUsername,
            // You might want to add these fields back
            username: emailUsername,
            referralId: _capturedReferralId,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Two tabs: Email and Phone
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.createAccount),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.email),
              Tab(text: l10n.phone),
            ],
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthQuickSignUpSuccess) {
              // context.go('/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                    SnackBar(content: Text(l10n.signUpFailed(state.message))));
            } else if (state is AuthEmailVerificationRequired) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.signUpSuccess)));
              context.pop();
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Form(
              key: _formKey,
              child: TabBarView(
                children: [
                  // --- Email Sign-Up Tab ---
                  _buildEmailSignUpTab(l10n, isLoading),
                  // --- Phone Sign-Up Tab ---
                  _buildPhoneSignUpTab(l10n, isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget for the Email Sign-Up tab
  Widget _buildEmailSignUpTab(AppLocalizations l10n, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.email),
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val!.isEmpty ? l10n.pleaseEnterAnEmail : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: l10n.password),
            obscureText: true,
            validator: (val) => val!.length < 6 ? l10n.passwordTooShort : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSignUpPressed,
                child: Text(l10n.continueButton),
              ),
            ),
          _buildBottomLinks(l10n),
        ],
      ),
    );
  }

  // Widget for the Phone Sign-Up tab
  Widget _buildPhoneSignUpTab(AppLocalizations l10n, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: l10n.phoneNumber),
            keyboardType: TextInputType.phone,
            validator: (val) =>
                val!.isEmpty ? l10n.pleaseEnterPhoneNumber : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement OTP sending logic
              },
              child: Text(l10n.sendOTP),
            ),
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const CircularProgressIndicator()
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSignUpPressed,
                child: Text(l10n.continueButton),
              ),
            ),
          _buildBottomLinks(l10n),
        ],
      ),
    );
  }

  // Helper for the "Already have an account?" links
  Widget _buildBottomLinks(AppLocalizations l10n) {
    return Column(
      children: [
        if (_capturedReferralId != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(l10n.referralId(_capturedReferralId!)),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.alreadyHaveAnAccount,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ],
    );
  }
}
