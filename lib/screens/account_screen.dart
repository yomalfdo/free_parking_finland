import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.authService});

  final AuthService authService;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUpMode = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUpMode) {
        await widget.authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await widget.authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForError(l10n, e.code));
    } catch (_) {
      setState(() => _errorMessage = l10n.authGenericError);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _messageForError(AppLocalizations l10n, String code) {
    switch (code) {
      case 'email-already-in-use':
        return l10n.authEmailAlreadyInUse;
      case 'weak-password':
        return l10n.authWeakPassword;
      case 'invalid-email':
        return l10n.authInvalidEmail;
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return l10n.authWrongCredentials;
      default:
        return l10n.authGenericError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = widget.authService.currentUser;
    // Treat "no session at all" (e.g. guest sign-in failed) the same as
    // guest: show the form so the user can still sign up or sign in
    // directly with email, which doesn't depend on anonymous auth.
    final hasRealAccount = user != null && !user.isAnonymous;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountScreenTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: hasRealAccount
              ? _buildSignedInView(l10n, user)
              : _buildAuthForm(l10n),
        ),
      ),
    );
  }

  Widget _buildSignedInView(AppLocalizations l10n, User user) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.signedInAsLabel(user.email ?? '')),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () async {
            await widget.authService.signOut();
            if (mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.signOutButton),
        ),
      ],
    );
  }

  Widget _buildAuthForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.guestStatusLabel),
          const SizedBox(height: 24),
          Text(
            _isSignUpMode ? l10n.signUpTitle : l10n.signInTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            validator: (value) =>
                (value == null || !value.contains('@')) ? l10n.authInvalidEmail : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.passwordLabel),
            validator: (value) =>
                (value == null || value.length < 6) ? l10n.authWeakPassword : null,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isSignUpMode ? l10n.signUpButton : l10n.signInButton),
          ),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => setState(() {
                      _isSignUpMode = !_isSignUpMode;
                      _errorMessage = null;
                    }),
            child: Text(_isSignUpMode ? l10n.switchToSignIn : l10n.switchToSignUp),
          ),
        ],
      ),
    );
  }
}
