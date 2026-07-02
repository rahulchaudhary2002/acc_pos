import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    // AuthProvider.verifyOtp() flips status to authenticated on success,
    // which _AuthGate reacts to by swapping in PosHomeScreen — see the note
    // in login_screen.dart on why no manual navigation happens here.
    await auth.verifyOtp(_codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // OtpScreen is rendered directly by _AuthGate (not pushed via
    // Navigator), so there's no underlying route for the system back
    // button to reveal — left as default, it would pop the app's only
    // route and show a black screen. Intercept it and drop back to the
    // login form via the auth status instead, same as the in-page button.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) auth.cancelOtp();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.gradientStart,
                AppColors.gradientMid,
                AppColors.gradientEnd,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.section),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppRadius.outerCard),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.info,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.card),
                          const Text(
                            'Enter verification code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'We sent a 6-digit code to your email.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.helper,
                          ),
                          const SizedBox(height: AppSpacing.section),
                          if (auth.errorMessage != null &&
                              auth.fieldErrors == null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.item,
                              ),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.dangerDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 8,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: '000000',
                              errorText: auth.fieldErrors?['code']?.first,
                            ),
                            onFieldSubmitted: (_) => _submit(auth),
                            validator: (value) {
                              if (value == null || value.trim().length != 6) {
                                return 'Enter the 6-digit code.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.section),
                          ElevatedButton(
                            onPressed: auth.isLoading
                                ? null
                                : () => _submit(auth),
                            style: AppButtonStyles.filled(AppColors.success),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Verify'),
                          ),
                          const SizedBox(height: AppSpacing.item),
                          TextButton(
                            onPressed: auth.isLoading ? null : auth.cancelOtp,
                            child: const Text('Back to login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
