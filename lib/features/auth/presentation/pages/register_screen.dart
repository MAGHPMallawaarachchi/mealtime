import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<RegisterFormState>();
  bool _isLoading = false;


  Future<void> _handleEmailRegister() async {
    final form = _formKey.currentState;
    if (form == null) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: form.emailValue,
        password: form.passwordValue,
      );

      if (userCredential?.user != null) {
        // Update display name
        await userCredential!.user!.updateDisplayName(form.nameValue);
        await userCredential.user!.reload();
      }
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _formKey.currentState?.clearLoading();
      }
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _formKey.currentState?.clearLoading();
      }
    }
  }

  void _handleLogin() {
    context.go('/login');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const AuthHeader(
      title: 'Sign Up',
      subtitle: 'Join Mealtime to start managing your meals',
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: MediaQuery.of(context).viewInsets.bottom > 0 ? 24.0 : 16.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 48),
                  RegisterForm(
                    key: _formKey,
                    onEmailRegister: _handleEmailRegister,
                    onGoogleRegister: _handleGoogleRegister,
                    onLogin: _handleLogin,
                    isLoading: _isLoading,
                  ),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }
}