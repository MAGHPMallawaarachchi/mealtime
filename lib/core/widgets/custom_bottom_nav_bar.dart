import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
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

    const primaryColor = Color(0xFFF58700);
    const inactiveColor = Colors.grey;

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
    const primaryColor = Color(0xFFF58700);

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnimatedNavItem(
            icon: PhosphorIcons.house(),
            activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
            index: 0,
          ),
          _buildAnimatedNavItem(
            icon: PhosphorIcons.magnifyingGlass(),
            activeIcon: PhosphorIcons.magnifyingGlass(),
            index: 1,
          ),
          _buildAnimatedCenterButton(primaryColor),
          _buildAnimatedNavItem(
            icon: PhosphorIcons.jarLabel(),
            activeIcon: PhosphorIcons.jarLabel(PhosphorIconsStyle.fill),
            index: 3,
          ),
          _buildAnimatedNavItem(
            icon: PhosphorIcons.user(),
            activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
  }) {
    final isActive = widget.currentIndex == index;

    return GestureDetector(
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
    );
  }

  Widget _buildAnimatedCenterButton(Color primaryColor) {
    return GestureDetector(
      onTap: () => widget.onTap(2),
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
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.chefHat(),
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
