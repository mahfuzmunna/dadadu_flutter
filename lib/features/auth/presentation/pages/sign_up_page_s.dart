// lib/features/auth/presentation/pages/sign_up_page.dart

import 'package:dadadu_app/core/util/check_for_deferred.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _capturedReferralId;

  // ✅ NEW: State variables for the new fields
  String? _selectedGender;
  final Set<String> _selectedInterests = {};
  String? _lookingFor;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkForReferral();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // ✅ Add validation for new fields
      if (_selectedGender == null ||
          _lookingFor == null ||
          _selectedInterests.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.pleaseCompleteAllFields)),
        );
        return;
      }

      context.read<AuthBloc>().add(AuthSignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _fullNameController.text.trim(),
            username: _usernameController.text.trim(),
            referralId: _capturedReferralId ?? '',
            // // ✅ Pass the new data
            // gender: _selectedGender!,
            // interestedIn: _selectedInterests.toList(),
            // lookingFor: _lookingFor!,
          ));
    }
  }

  Future<void> _checkForReferral() async {
    final referralId = await checkForDeferredReferral();
    if (mounted) {
      setState(() {
        _capturedReferralId = referralId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccount)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSignUpSuccess) {
            context.go('/upload-profile-photo');
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(labelText: l10n.fullName),
                    validator: (val) =>
                        val!.isEmpty ? l10n.pleaseEnterYourName : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: l10n.username),
                    validator: (val) =>
                        val!.isEmpty ? l10n.pleaseEnterAUsername : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        val!.isEmpty ? l10n.pleaseEnterAnEmail : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                    validator: (val) =>
                        val!.length < 6 ? l10n.passwordTooShort : null,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // ✅ NEW: Gender Selection
                  _buildSectionHeader(context, 'I am a'),
                  SegmentedButton<String>(
                    emptySelectionAllowed: true,
                    segments: [
                      ButtonSegment(
                          value: AppLocalizations.of(context)!.man,
                          label: Text(AppLocalizations.of(context)!.man)),
                      ButtonSegment(
                          value: AppLocalizations.of(context)!.woman,
                          label: Text(AppLocalizations.of(context)!.woman)),
                    ],
                    selected: _selectedGender != null ? {_selectedGender!} : {},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedGender = selection.first);
                    },
                  ),
                  const SizedBox(height: 24),

                  // ✅ NEW: Interested In Selection
                  _buildSectionHeader(
                      context, AppLocalizations.of(context)!.interestedIn),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      AppLocalizations.of(context)!.man,
                      AppLocalizations.of(context)!.woman
                    ].map((interest) {
                      return FilterChip(
                        label: Text(interest),
                        selected: _selectedInterests.contains(interest),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInterests.add(interest);
                            } else {
                              _selectedInterests.remove(interest);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ✅ NEW: Looking For Selection
                  _buildSectionHeader(
                      context, AppLocalizations.of(context)!.lookingFor),
                  SegmentedButton<String>(
                    emptySelectionAllowed: true,
                    multiSelectionEnabled: false,
                    segments: [
                      ButtonSegment(
                          value: AppLocalizations.of(context)!.love,
                          label: Text(l10n.love)),
                      ButtonSegment(
                          value: AppLocalizations.of(context)!.business,
                          label: Text(l10n.business)),
                      ButtonSegment(
                          value: AppLocalizations.of(context)!.entertainment,
                          label: Text(l10n.entertainment)),
                    ],
                    selected: _lookingFor != null ? {_lookingFor!} : {},
                    onSelectionChanged: (selection) {
                      setState(() => _lookingFor = selection.first);
                    },
                  ),
                  const SizedBox(height: 32),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onSignUpPressed,
                        child: Text(l10n.continueButton),
                      ),
                    ),
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
                              color: theme.colorScheme.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n.signIn),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper for consistent section headers
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
