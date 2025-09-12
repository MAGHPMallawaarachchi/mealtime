import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileMenuBottomSheet extends StatelessWidget {
  final VoidCallback onSignOut;

  const ProfileMenuBottomSheet({
    super.key,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.gear(),
                  title: 'Settings & Preferences',
                  subtitle: 'Manage your account settings',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/settings');
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.plus(),
                  title: 'Create New Recipe',
                  subtitle: 'Share your culinary creation',
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/create-recipe');
                  },
                ),
                const SizedBox(height: 4),
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.shareNetwork(),
                  title: 'Share Profile',
                  subtitle: 'Let others discover your recipes',
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.info(),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text('Share profile feature coming soon'),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: PhosphorIcons.signOut(),
                  title: 'Sign Out',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSignOut();
                  },
                  isDanger: true,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required PhosphorIconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final iconColor = isDanger ? Colors.red : AppColors.primary;
    final titleColor = isDanger ? Colors.red : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDanger
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PhosphorIcon(
                  icon,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              PhosphorIcon(
                PhosphorIcons.caretRight(),
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, VoidCallback onSignOut) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ProfileMenuBottomSheet(onSignOut: onSignOut);
      },
    );
  }
}