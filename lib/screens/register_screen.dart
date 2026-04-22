import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

/// Register/Sign Up screen with full validation and Material 3 design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // UI state variables
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

  /// Validate Full Name - must contain first and last name
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.split(' ').where((word) => word.isNotEmpty).length < 2) {
      return 'Please enter your first and last name';
    }
    return null;
  }

  /// Validate Email - must be valid email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate Phone Number - must be exactly 10 digits
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  /// Validate Password - must be at least 8 characters
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validate Confirm Password - must match password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Handle Register button press
  /// Validates all inputs and shows errors if invalid
  /// Shows success message and navigates to login if valid
  Future<void> _handleRegister() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      // Validation failed - errors are shown inline by TextFormField
      return;
    }

    // Check if Terms & Conditions is accepted
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    // All validations passed - proceed with registration
    setState(() => _isLoading = true);

    try {
      // Call placeholder register function
      final success = await registerUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Successful!'),
              backgroundColor: AppColors.green,
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to home screen
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('home');
            }
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Placeholder register function - replace with actual backend call
  /// Returns true if registration is successful, false otherwise
  Future<bool> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Placeholder: Always return true for now
    // TODO: Replace with actual backend/Firebase authentication
    debugPrint('Registering user: $fullName, $email, $phone');
    
    return true; // Simulate successful registration
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxMobileWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),

                    // App Logo/Title
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.cyan, AppColors.blue],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        color: AppColors.textCyanLight,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Full Name Field
                    CustomInput(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline,
                      validator: _validateFullName,
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    CustomInput(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // Phone Number Field
                    CustomInput(
                      label: 'Phone Number',
                      hint: 'Enter 10-digit phone number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      validator: _validatePhone,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomInput(
                      label: 'Password',
                      hint: 'Enter your password (min 8 characters)',
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      prefixIcon: Icons.lock_outline,
                      validator: _validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.cyan.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomInput(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      validator: _validateConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.cyan.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() => _showConfirmPassword = !_showConfirmPassword);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Terms & Conditions Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.cyan,
                          checkColor: Colors.white,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: Text(
                              'I accept the Terms & Conditions',
                              style: TextStyle(
                                color: AppColors.textCyanLight,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Register Button
                    GradientButton(
                      text: 'Register',
                      onPressed: _isLoading ? null : _handleRegister,
                      isLoading: _isLoading,
                      width: double.infinity,
                      height: 52,
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textCyanLight,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('login');
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
