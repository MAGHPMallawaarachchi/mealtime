import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/explore/presentation/pages/explore_screen.dart';
import '../../features/meal_planner/presentation/pages/meal_planner_screen.dart';
import '../../features/pantry/presentation/pages/pantry_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  // Create a GlobalKey for the meal planner screen to access its methods
  final GlobalKey<State<MealPlannerScreen>> _mealPlannerKey = GlobalKey<State<MealPlannerScreen>>();
  
  // Pre-create all screens to eliminate any build flickering
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const ExploreScreen(),
      MealPlannerScreen(key: _mealPlannerKey),
      const PantryScreen(),
      const ProfileScreen(),
    ];
  }

  int _getCurrentIndex() {
    try {
      final location = GoRouterState.of(context).uri.toString();
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
    // Access the meal planner screen's add meal functionality
    final mealPlannerState = _mealPlannerKey.currentState;
    if (mealPlannerState != null && mealPlannerState is State<MealPlannerScreen>) {
      // We need to cast and call the showAddMealOptions method
      (mealPlannerState as dynamic).showAddMealOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: currentIndex, children: _screens),
      extendBody: true, // Allow body to extend behind floating button
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        onCenterButtonTap: currentIndex == 2 ? _onMealPlannerAddMeal : null,
      ),
    );
  }
}
