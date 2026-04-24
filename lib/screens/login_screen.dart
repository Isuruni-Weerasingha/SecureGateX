import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final Function(String userName) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted && user != null) {
        Navigator.of(context).pushReplacementNamed('home');
      }
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.parseError(e));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.06),

                // ── Logo ──────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: size.width * 0.18,
                    height: size.width * 0.18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cyan, AppColors.blue],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock,
                      size: size.width * 0.09,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: size.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Sign in to access your smart lock',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textCyanLight,
                    fontSize: size.width * 0.035,
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // ── Form ──────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInput(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      CustomInput(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        prefixIcon: Icons.lock_outline,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Minimum 6 characters';
                          return null;
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.cyan.withOpacity(0.6),
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),

                      SizedBox(height: size.height * 0.035),

                      // ── Login Button ──────────────────────────────────
                      GradientButton(
                        text: 'Login',
                        onPressed: _isLoading ? null : _handleLogin,
                        isLoading: _isLoading,
                        width: double.infinity,
                        height: size.height * 0.065,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                // ── Divider ───────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.cardBorder)),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textCyanLighter,
                          fontSize: size.width * 0.03,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.cardBorder)),
                  ],
                ),

                SizedBox(height: size.height * 0.03),

                // ── Biometric Button ──────────────────────────────────────
                CustomButton(
                  text: 'Login with Biometric',
                  icon: Icons.fingerprint,
                  isOutlined: true,
                  borderColor: AppColors.cardBorder,
                  backgroundColor: AppColors.cardBackground,
                  textColor: AppColors.cyan,
                  width: double.infinity,
                  height: size.height * 0.065,
                  onPressed: () {
                    // Biometric integration placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Biometric login coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),

                SizedBox(height: size.height * 0.03),

                // ── Register Link ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textCyanLight,
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('register'),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
