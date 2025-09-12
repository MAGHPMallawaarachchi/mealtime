import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback?
  onCenterButtonTap; // Custom callback for center button when on meal planner

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterButtonTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Color?>> _colorAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.1).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    const primaryColor = AppColors.primary;
    const inactiveColor = AppColors.textSecondary;

    _colorAnimations = _controllers
        .map(
          (controller) =>
              ColorTween(begin: inactiveColor, end: primaryColor).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
        )
        .toList();

    // Initialize active tab animation
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateAnimations(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _updateAnimations(int oldIndex, int newIndex) {
    if (oldIndex < _controllers.length) {
      _controllers[oldIndex].reverse();
    }
    if (newIndex < _controllers.length) {
      _controllers[newIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        boxShadow: [
          // Single subtle upward shadow for gentle separation
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
          // Very soft ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: Offset(0, -8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Main navigation bar with notch
          ClipPath(
            clipper: _BottomNavBarClipper(),
            child: Container(
              height: 70,
              decoration: const BoxDecoration(color: AppColors.background),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnimatedNavItem(
                    icon: PhosphorIcons.house(),
                    activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                    index: 0,
                    context: context,
                  ),
                  _buildAnimatedNavItem(
                    icon: PhosphorIcons.magnifyingGlass(),
                    activeIcon: PhosphorIcons.magnifyingGlass(),
                    index: 1,
                    context: context,
                  ),
                  // Empty space for floating button
                  const SizedBox(width: 80),
                  _buildAnimatedNavItem(
                    icon: PhosphorIcons.jarLabel(),
                    activeIcon: PhosphorIcons.jarLabel(PhosphorIconsStyle.fill),
                    index: 3,
                    context: context,
                  ),
                  _buildAnimatedNavItem(
                    icon: PhosphorIcons.user(),
                    activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                    index: 4,
                    context: context,
                  ),
                ],
              ),
            ),
          ),
          // Floating center button
          Positioned(
            top: -32, // Lifted much higher for pronounced floating effect
            child: _buildFloatingCenterButton(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required BuildContext context,
  }) {
    final isActive = widget.currentIndex == index;

    return Semantics(
      label: _getSemanticLabel(context, index),
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[index].value,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: PhosphorIcon(
                  isActive ? activeIcon : icon,
                  size: 28,
                  color: _colorAnimations[index].value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingCenterButton(Color primaryColor) {
    final bool isOnMealPlanner = widget.currentIndex == 2;
    final IconData iconData = isOnMealPlanner
        ? PhosphorIcons.plus()
        : PhosphorIcons.chefHat();

    return Semantics(
      label: AppLocalizations.of(context)?.mealPlanner,
      button: true,
      selected: isOnMealPlanner,
      child: GestureDetector(
        onTap: () {
          if (isOnMealPlanner && widget.onCenterButtonTap != null) {
            // If on meal planner and custom callback is provided, use it
            widget.onCenterButtonTap!();
          } else {
            // Otherwise use normal navigation
            widget.onTap(2);
          }
        },
        child: AnimatedBuilder(
          animation: _controllers[2],
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimations[2].value,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    // Clean drop shadow only
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: PhosphorIcon(
                      iconData,
                      key: ValueKey(iconData.codePoint),
                      size: 32,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom clipper to create the notch/dent in the navigation bar
class _BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double cornerRadius = 25; // Rounded corners
    final double notchRadius = 65; // Larger radius for smoother curves
    final double notchDepth = 35; // Slightly shallower for gentler curve
    final double notchWidth = 120; // Wider for more gradual transition
    final double centerX = size.width / 2;

    // Start from top-left with rounded corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Draw to the start of the notch with more gradual approach
    path.lineTo(centerX - notchWidth / 2, 0);

    // Create ultra-smooth curved notch with gentler control points
    path.cubicTo(
      centerX - notchRadius * 0.5, // Less aggressive first control point
      0,
      centerX - notchRadius * 0.6, // Gentler approach to depth
      notchDepth * 0.9, // Slightly less depth for smoothness
      centerX,
      notchDepth, // End point (center of notch)
    );

    path.cubicTo(
      centerX + notchRadius * 0.6, // Mirror the approach
      notchDepth * 0.9,
      centerX + notchRadius * 0.5, // Less aggressive exit
      0,
      centerX + notchWidth / 2,
      0, // End point
    );

    // Continue to top-right with rounded corner
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Draw down and complete the rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

extension on _CustomBottomNavBarState {
  String _getSemanticLabel(BuildContext context, int index) {
    final localizations = AppLocalizations.of(context);
    switch (index) {
      case 0:
        return localizations!.home;
      case 1:
        return localizations!.explore;
      case 2:
        return localizations!.mealPlanner;
      case 3:
        return localizations!.pantry;
      case 4:
        return localizations!.profile;
      default:
        return '';
    }
  }
}
