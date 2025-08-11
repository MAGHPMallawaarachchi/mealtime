import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: PhosphorIcon(
          PhosphorIcons.signOut(),
          size: 24,
          color: Colors.red,
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _signOut();
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _authService.signOut();
      // Navigation will be handled automatically by router redirect
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFF58700).withOpacity(0.2),
                    backgroundImage: _user?.photoURL != null
                        ? NetworkImage(_user!.photoURL!)
                        : null,
                    child: _user?.photoURL == null
                        ? PhosphorIcon(
                            PhosphorIcons.user(),
                            size: 60,
                            color: const Color(0xFFF58700),
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.user()),
                          title: const Text('Edit Profile'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to edit profile screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit profile feature coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.house()),
                          title: const Text('Household'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to household management screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Household management coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.bell()),
                          title: const Text('Notifications'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to notifications settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification settings coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.translate()),
                          title: const Text('Language'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to language settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Language settings coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.questionMark()),
                          title: const Text('Help & Support'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to help screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Help & Support coming soon'),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: PhosphorIcon(PhosphorIcons.info()),
                          title: const Text('About'),
                          trailing: PhosphorIcon(PhosphorIcons.caretRight()),
                          onTap: () {
                            // TODO: Navigate to about screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('About screen coming soon'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showLogoutConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }
}