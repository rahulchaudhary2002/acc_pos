import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    // AuthProvider.login() flips status to otpRequired on success, which
    // _AuthGate reacts to by swapping in OtpScreen — no manual navigation
    // here, so logout/forceLogout later can always find _AuthGate live in
    // the tree to route back to LoginScreen.
    await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientMid, AppColors.gradientEnd],
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
                        Image.asset(
                          'assets/images/logo.png',
                          height: 96,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: AppSpacing.card),
                        const Text(
                          'POS Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to continue to the terminal',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.helper,
                        ),
                        const SizedBox(height: AppSpacing.section),
                        if (auth.errorMessage != null && auth.fieldErrors == null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.item),
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.dangerDark, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: auth.fieldErrors?['email']?.first,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Email is required.';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.item),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(auth),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: auth.fieldErrors?['password']?.first,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required.';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.section),
                        ElevatedButton(
                          onPressed: auth.isLoading ? null : () => _submit(auth),
                          style: AppButtonStyles.filled(AppColors.success),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Log In'),
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
    );
  }
}
