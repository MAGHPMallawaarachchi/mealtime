import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/meal_planner/presentation/pages/meal_planner_screen.dart';
import '../../features/pantry/presentation/pages/pantry_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/meal_planner/domain/models/meal_planner_return_context.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Pre-create static screens (non-contextual ones)
  late final List<Widget?> _staticScreens;
  VoidCallback? _mealPlannerAddMealCallback;

  @override
  void initState() {
    super.initState();
    _staticScreens = [
      const HomeScreen(),
      const ExploreScreen(),
      null, // MealPlannerScreen will be created dynamically
      const PantryScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _getMealPlannerScreen() {
    try {
      final routerState = GoRouterState.of(context);
      final returnContext = MealPlannerReturnContext.fromQueryParameters(
        routerState.uri.queryParameters,
      );
      
      return MealPlannerScreen(
        onRegisterAddMealCallback: (callback) {
          _mealPlannerAddMealCallback = callback;
        },
        returnContext: returnContext,
      );
    } catch (e) {
      // Fallback to default MealPlannerScreen if context retrieval fails
      return MealPlannerScreen(
        onRegisterAddMealCallback: (callback) {
          _mealPlannerAddMealCallback = callback;
        },
      );
    }
  }

  Widget _getScreenAtIndex(int index) {
    if (index == 2) {
      // Return dynamic meal planner screen with context
      return _getMealPlannerScreen();
    } else {
      // Return pre-created static screen
      return _staticScreens[index]!;
    }
  }

  int _getCurrentIndex() {
    try {
      final location = GoRouterState.of(context).uri.path;
      switch (location) {
        case '/home':
          return 0;
        case '/explore':
          return 1;
        case '/meal-planner':
          return 2;
        case '/pantry':
          return 3;
        case '/profile':
          return 4;
        default:
          return 0; // Fallback to home
      }
    } catch (e) {
      // Fallback to home if route context is unavailable
      return 0;
    }
  }

  void _onTabTapped(int index) {
    final routes = [
      '/home',
      '/explore',
      '/meal-planner',
      '/pantry',
      '/profile',
    ];
    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
  }

  void _onMealPlannerAddMeal() {
    // Trigger add meal functionality through callback
    _mealPlannerAddMealCallback?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    // Build screens dynamically to handle context properly
    final screens = [
      _getScreenAtIndex(0), // HomeScreen
      _getScreenAtIndex(1), // ExploreScreen  
      _getScreenAtIndex(2), // MealPlannerScreen (dynamic)
      _getScreenAtIndex(3), // PantryScreen
      _getScreenAtIndex(4), // ProfileScreen
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: currentIndex, children: screens),
      extendBody: true, // Allow body to extend behind floating button
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        onCenterButtonTap: currentIndex == 2 ? _onMealPlannerAddMeal : null,
      ),
    );
  }
}
