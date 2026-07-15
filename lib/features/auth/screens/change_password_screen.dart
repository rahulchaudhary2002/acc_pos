import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

/// Mirrors the password section of the web `Profile.jsx` page (current
/// password + new password + confirmation, same `PUT /auth/profile`
/// endpoint) as a standalone screen reachable from Others/Settings.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, List<String>>? _fieldErrors;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _fieldErrors = null;
    });

    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;

    try {
      await auth.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.changePasswordScreenSuccessMessage)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.fieldErrors == null ? e.message : null;
        _fieldErrors = e.fieldErrors;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePasswordScreenTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.card),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.changePasswordScreenSubtitle, style: AppTextStyles.helper),
                const SizedBox(height: AppSpacing.section),
                if (_errorMessage != null)
                  ErrorBanner(message: _errorMessage!, onDismiss: () => setState(() => _errorMessage = null)),
                _PasswordField(
                  controller: _currentPasswordController,
                  label: l10n.changePasswordScreenCurrentPasswordLabel,
                  obscure: !_showCurrent,
                  onToggleObscure: () => setState(() => _showCurrent = !_showCurrent),
                  errorText: _fieldErrors?['current_password']?.first,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.changePasswordScreenCurrentPasswordRequiredError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.item),
                _PasswordField(
                  controller: _newPasswordController,
                  label: l10n.changePasswordScreenNewPasswordLabel,
                  obscure: !_showNew,
                  onToggleObscure: () => setState(() => _showNew = !_showNew),
                  errorText: _fieldErrors?['password']?.first,
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return l10n.changePasswordScreenNewPasswordLengthError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.item),
                _PasswordField(
                  controller: _confirmPasswordController,
                  label: l10n.changePasswordScreenConfirmPasswordLabel,
                  obscure: !_showConfirm,
                  onToggleObscure: () => setState(() => _showConfirm = !_showConfirm),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return l10n.changePasswordScreenConfirmPasswordMismatchError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.section),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: AppButtonStyles.filled(AppColors.success),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.changePasswordScreenSubmitButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? errorText;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleObscure,
    this.errorText,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggleObscure,
        ),
      ),
      validator: validator,
    );
  }
}
