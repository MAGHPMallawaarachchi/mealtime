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

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Pre-create all screens to eliminate any build flickering
  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    MealPlannerScreen(),
    PantryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Start with the animation completed
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize from current route after dependencies are available
    _initializeFromCurrentRoute();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeFromCurrentRoute() {
    try {
      final location = GoRouterState.of(context).uri.toString();
      int newIndex;
      
      switch (location) {
        case '/home':
          newIndex = 0;
          break;
        case '/explore':
          newIndex = 1;
          break;
        case '/meal-planner':
          newIndex = 2;
          break;
        case '/pantry':
          newIndex = 3;
          break;
        case '/profile':
          newIndex = 4;
          break;
        default:
          newIndex = 0;
      }
      
      if (_currentIndex != newIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    } catch (e) {
      // Fallback to home if route context is not available
      if (_currentIndex != 0) {
        setState(() {
          _currentIndex = 0;
        });
      }
    }
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      // Smooth transition with subtle animation
      _animationController.reset();
      
      setState(() {
        _currentIndex = index;
      });
      
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      extendBody: true, // Allow body to extend behind floating button
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

