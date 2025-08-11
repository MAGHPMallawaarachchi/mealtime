import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import 'custom_text_field.dart';
import 'loading_banner.dart';
import 'primary_button.dart';
import 'social_login_button.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onEmailLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignUp;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onEmailLogin,
    required this.onGoogleLogin,
    required this.onForgotPassword,
    required this.onSignUp,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _loadingMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get isFormValid => _formKey.currentState?.validate() ?? false;

  String get email => _emailController.text.trim();
  String get password => _passwordController.text;

  void _handleEmailLogin() {
    if (isFormValid) {
      setState(() {
        _loadingMessage = 'Signing in...';
      });
      widget.onEmailLogin();
    }
  }

  void _handleGoogleLogin() {
    setState(() {
      _loadingMessage = 'Authenticating with Google...';
    });
    widget.onGoogleLogin();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void clearLoading() {
    setState(() {
      _loadingMessage = '';
    });
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

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        GestureDetector(
          onTap: widget.onSignUp,
          child: const Text(
            'Sign Up',
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.onForgotPassword,
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Log In',
            onPressed: widget.isLoading ? null : _handleEmailLogin,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          SocialLoginButton(
            text: 'Continue with Google',
            icon: _buildGoogleIcon(),
            onPressed: widget.isLoading ? null : _handleGoogleLogin,
            isLoading: widget.isLoading,
          ),
          const SizedBox(height: 32),
          _buildSignUpPrompt(),
        ],
      ),
    );
  }

  // Getters for parent to access form data
  String get emailValue => email;
  String get passwordValue => password;
}