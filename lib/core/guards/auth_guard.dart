import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  
  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return child;
        }
        
        return fallback ?? const AuthRequiredScreen();
      },
    );
  }
}

class AuthRequiredScreen extends StatelessWidget {
  const AuthRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Please sign in to access this feature.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to login will be handled by router redirect
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF58700),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}