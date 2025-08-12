import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import 'custom_text_field.dart';
import 'loading_banner.dart';
import 'primary_button.dart';
import 'social_login_button.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onEmailRegister;
  final VoidCallback onGoogleRegister;
  final VoidCallback onLogin;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onEmailRegister,
    required this.onGoogleRegister,
    required this.onLogin,
    this.isLoading = false,
  });

  @override
  State<RegisterForm> createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _loadingMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get isFormValid => _formKey.currentState?.validate() ?? false;

  String get name => _nameController.text.trim();
  String get email => _emailController.text.trim();
  String get password => _passwordController.text;

  void _handleEmailRegister() {
    if (isFormValid) {
      setState(() {
        _loadingMessage = 'Creating your account...';
      });
      widget.onEmailRegister();
    }
  }

  void _handleGoogleRegister() {
    setState(() {
      _loadingMessage = 'Setting up with Google...';
    });
    widget.onGoogleRegister();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void clearLoading() {
    setState(() {
      _loadingMessage = '';
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
      ),
      child: Image.network(
        'https://developers.google.com/identity/images/g-logo.png',
        width: 20,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: PhosphorIcon(
              PhosphorIcons.googleLogo(),
              size: 16,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: widget.onLogin,
          child: const Text(
            'Login',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          LoadingBanner(
            message: _loadingMessage,
            isVisible: widget.isLoading,
          ),
          CustomTextField(
            label: 'Full Name',
            controller: _nameController,
            keyboardType: TextInputType.name,
            validator: _validateName,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            enabled: !widget.isLoading,
            suffixIcon: IconButton(
              onPressed: _togglePasswordVisibility,
              icon: PhosphorIcon(
                _obscurePassword
                    ? PhosphorIcons.eye()
                    : PhosphorIcons.eyeSlash(),
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            enabled: !widget.isLoading,
            suffixIcon: IconButton(
              onPressed: _toggleConfirmPasswordVisibility,
              icon: PhosphorIcon(
                _obscureConfirmPassword
                    ? PhosphorIcons.eye()
                    : PhosphorIcons.eyeSlash(),
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Create Account',
            onPressed: widget.isLoading ? null : _handleEmailRegister,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          SocialLoginButton(
            text: 'Continue with Google',
            icon: _buildGoogleIcon(),
            onPressed: widget.isLoading ? null : _handleGoogleRegister,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 32),
          _buildLoginPrompt(),
        ],
      ),
    );
  }

  // Getters for parent to access form data
  String get nameValue => name;
  String get emailValue => email;
  String get passwordValue => password;
}