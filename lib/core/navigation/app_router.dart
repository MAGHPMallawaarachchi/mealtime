import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../guards/auth_guard.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final _authService = AuthService();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = _authService.currentUser;
      final isLoggedIn = user != null;
      
      final authRoutes = ['/login', '/register'];
      final isAuthRoute = authRoutes.contains(state.uri.toString());
      
      if (!isLoggedIn && !isAuthRoute && state.uri.toString() != '/' && state.uri.toString() != '/onboarding') {
        return '/login';
      }
      
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => AuthGuard(
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => AuthGuard(
          child: const ProfileScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
