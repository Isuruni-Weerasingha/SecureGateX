import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Register ─────────────────────────────────────────────────────────────
  // Validates form → checks terms → calls AuthService.signUp → saves to Firestore
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showMessage('Please accept the Terms & Conditions', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _fullNameController.text,
        phone: _phoneController.text,
      );

      if (mounted) {
        _showMessage('Account created successfully!', isError: false);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pushReplacementNamed('home');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(AuthService.parseError(e), isError: true);
    } catch (e) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.red : AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Validators ───────────────────────────────────────────────────────────
  String? _validateFullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().split(' ').where((w) => w.isNotEmpty).length < 2) {
      return 'Enter first and last name';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Phone number is required';
    if (v.replaceAll(RegExp(r'[^\d]'), '').length != 10) {
      return 'Phone must be exactly 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.03),

                  // ── Logo ────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: size.width * 0.2,
                      height: size.width * 0.2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.cyan, AppColors.blue],
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                        size: size.width * 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // ── Title ───────────────────────────────────────────────
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Sign up to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textCyanLight,
                      fontSize: size.width * 0.035,
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // ── Fields ──────────────────────────────────────────────
                  CustomInput(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person_outline,
                    validator: _validateFullName,
                  ),
                  SizedBox(height: size.height * 0.02),

                  CustomInput(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: size.height * 0.02),

                  CustomInput(
                    label: 'Phone Number',
                    hint: 'Enter 10-digit phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: _validatePhone,
                  ),
                  SizedBox(height: size.height * 0.02),

                  CustomInput(
                    label: 'Password',
                    hint: 'Minimum 8 characters',
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    prefixIcon: Icons.lock_outline,
                    validator: _validatePassword,
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
                  SizedBox(height: size.height * 0.02),

                  CustomInput(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    prefixIcon: Icons.lock_outline,
                    validator: _validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.cyan.withOpacity(0.6),
                      ),
                      onPressed: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Terms Checkbox ───────────────────────────────────────
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        activeColor: AppColors.cyan,
                        checkColor: Colors.white,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _acceptTerms = !_acceptTerms),
                          child: Text(
                            'I accept the Terms & Conditions',
                            style: TextStyle(
                              color: AppColors.textCyanLight,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.035),

                  // ── Register Button ──────────────────────────────────────
                  GradientButton(
                    text: 'Create Account',
                    onPressed: _isLoading ? null : _handleRegister,
                    isLoading: _isLoading,
                    width: double.infinity,
                    height: size.height * 0.065,
                  ),

                  SizedBox(height: size.height * 0.025),

                  // ── Login Link ───────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textCyanLight,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('login'),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontSize: size.width * 0.035,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
