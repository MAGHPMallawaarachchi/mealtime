import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/meal_slot.dart';
import '../widgets/weekly_calendar_view.dart';
import '../widgets/todays_prep_view.dart';
import '../widgets/add_meal_modal.dart';

enum MealPlannerTab { calendar, today }

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MealPlannerTab _currentTab = MealPlannerTab.calendar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  // Expose the add meal functionality to parent widgets
  void showAddMealOptions() {
    _showAddMealOptions();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentTab = _tabController.index == 0
          ? MealPlannerTab.calendar
          : MealPlannerTab.today;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  WeeklyCalendarView(
                    onMealSlotTap: _handleMealSlotTap,
                    onMealSlotLongPress: _handleMealSlotLongPress,
                  ),
                  TodaysPrepView(onMealTap: _handleMealTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meal Planner',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _getCurrentTabSubtitle(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: _showAutoFillDialog,
                icon: PhosphorIcon(
                  PhosphorIcons.magicWand(),
                  color: AppColors.primary,
                ),
                tooltip: 'Auto-fill meals',
              ),
              IconButton(
                onPressed: _showMealPlanOptions,
                icon: PhosphorIcon(
                  PhosphorIcons.dotsThreeVertical(),
                  color: AppColors.textPrimary,
                ),
                tooltip: 'More options',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(PhosphorIcons.calendar(), size: 18),
                const SizedBox(width: 8),
                const Text('Weekly'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PhosphorIcon(PhosphorIcons.clock(), size: 18),
                const SizedBox(width: 8),
                const Text('Today'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _getCurrentTabSubtitle() {
    switch (_currentTab) {
      case MealPlannerTab.calendar:
        return 'Plan your weekly meals';
      case MealPlannerTab.today:
        return 'Today\'s cooking schedule';
    }
  }

  void _handleMealSlotTap(MealSlot mealSlot, DateTime date) {
    if (mealSlot.isEmpty) {
      _showAddMealModal(mealSlot, date);
    } else {
      _showMealDetailModal(mealSlot, date);
    }
  }

  void _handleMealSlotLongPress(MealSlot mealSlot, DateTime date) {
    _showMealContextMenu(mealSlot, date);
  }

  void _handleMealTap(MealSlot mealSlot) {
    _showMealDetailModal(mealSlot, DateTime.now());
  }

  void _showAddMealModal(MealSlot mealSlot, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddMealModal(
        mealSlot: mealSlot,
        date: date,
        onMealSelected: (updatedSlot) {
          // TODO: Update the meal plan data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${updatedSlot.type.displayName} added successfully!',
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showMealDetailModal(MealSlot mealSlot, DateTime date) {
    // TODO: Implement meal detail modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View meal details'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMealContextMenu(MealSlot mealSlot, DateTime date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.pencil()),
              title: const Text('Edit Meal'),
              onTap: () {
                Navigator.pop(context);
                _showMealDetailModal(mealSlot, date);
              },
            ),
            if (!mealSlot.isLocked)
              ListTile(
                leading: PhosphorIcon(PhosphorIcons.lock()),
                title: const Text('Lock Meal'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement lock functionality
                },
              )
            else
              ListTile(
                leading: PhosphorIcon(PhosphorIcons.lockOpen()),
                title: const Text('Unlock Meal'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement unlock functionality
                },
              ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.trash()),
              title: const Text('Remove Meal'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement remove functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Meal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.magnifyingGlass()),
              title: const Text('Browse Recipes'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to recipe browser
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.recycle()),
              title: const Text('Use Leftovers'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show leftover options
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.plus()),
              title: const Text('Custom Meal'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show custom meal dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoFillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-fill Week'),
        content: const Text(
          'Automatically fill empty meal slots with suggestions based on your pantry, leftovers, and seasonal recipes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement auto-fill functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Auto-fill feature coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Auto-fill'),
          ),
        ],
      ),
    );
  }

  void _showMealPlanOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.shoppingCart()),
              title: const Text('Generate Shopping List'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to shopping list generation
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.clockCounterClockwise()),
              title: const Text('View Previous Weeks'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show week history
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.copy()),
              title: const Text('Duplicate Week'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement week duplication
              },
            ),
            ListTile(
              leading: PhosphorIcon(PhosphorIcons.trash()),
              title: const Text('Clear All Meals'),
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                // TODO: Show clear confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
