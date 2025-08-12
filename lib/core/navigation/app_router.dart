import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/onboarding/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/meal_planner/presentation/pages/meal_planner_screen.dart';
import '../../features/pantry/presentation/pages/pantry_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/recipes/presentation/pages/recipe_detail_screen.dart';
import '../guards/auth_guard.dart';
import '../services/auth_service.dart';
import 'main_scaffold.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  
  AuthNotifier(this._authService) {
    _authService.authStateChanges.listen((_) {
      notifyListeners();
    });
  }
}

class AppRouter {
  static final _authService = AuthService();
  static final _authNotifier = AuthNotifier(_authService);

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final user = _authService.currentUser;
      final isLoggedIn = user != null;
      
      final authRoutes = ['/login', '/register'];
      final isAuthRoute = authRoutes.contains(state.uri.toString());
      final mainAppRoutes = ['/home', '/explore', '/meal-planner', '/pantry', '/profile'];
      final isMainAppRoute = mainAppRoutes.contains(state.uri.toString());
      
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
      ShellRoute(
        builder: (context, state, child) => AuthGuard(
          child: MainScaffold(child: child),
        ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/meal-planner',
            name: 'meal-planner',
            builder: (context, state) => const MealPlannerScreen(),
          ),
          GoRoute(
            path: '/pantry',
            name: 'pantry',
            builder: (context, state) => const PantryScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/recipe/:recipeId',
        name: 'recipe-detail',
        builder: (context, state) {
          final recipeId = state.pathParameters['recipeId']!;
          return RecipeDetailScreen(recipeId: recipeId);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
