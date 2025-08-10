import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIcons.forkKnife(),
              size: 80,
              color: const Color(0xFFF58700),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome ${user?.displayName?.split(' ').first ?? 'back'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your smart meal planning journey begins here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildFeatureCard(
                  icon: PhosphorIcons.cookingPot(),
                  title: 'Pantry',
                  subtitle: 'Manage ingredients',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pantry feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: PhosphorIcons.book(),
                  title: 'Recipes',
                  subtitle: 'Discover meals',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipes feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: PhosphorIcons.calendar(),
                  title: 'Meal Planner',
                  subtitle: 'Plan your week',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Meal Planner feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildFeatureCard(
                  icon: PhosphorIcons.shoppingCart(),
                  title: 'Shopping List',
                  subtitle: 'Never forget items',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Shopping List feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(icon, size: 48, color: const Color(0xFFF58700)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
