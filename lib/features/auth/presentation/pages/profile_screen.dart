import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../user_recipes/presentation/providers/user_recipes_providers.dart';
import '../widgets/favorites_grid.dart';
import '../widgets/user_recipes_grid.dart';
import '../widgets/profile_menu_bottom_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  
  const ProfileScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _imagePicker = ImagePicker();
  User? _user;
  String? _profilePictureUrl;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _tabController = TabController(
      length: 2, 
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfilePicture();
      ref.read(favoritesProvider.notifier).loadUserFavorites();
      ref.read(userRecipesProvider.notifier).loadUserRecipes();
    });
  }

  Future<void> _loadUserProfilePicture() async {
    try {
      final profilePictureUrl = await _authService.getUserProfilePictureUrl();
      print('Loaded profile picture URL: ${profilePictureUrl?.substring(0, 50)}...'); // Debug log
      if (mounted) {
        setState(() {
          _profilePictureUrl = profilePictureUrl;
        });
      }
    } catch (e) {
      // If there's an error loading the profile picture, just use the default
      print('Error loading profile picture: $e');
    }
  }

  Widget _buildProfileImage() {
    print('Building profile image. URL: ${_profilePictureUrl != null ? _profilePictureUrl!.substring(0, 30) + "..." : "null"}'); // Debug
    
    if (_profilePictureUrl == null || _profilePictureUrl!.isEmpty) {
      print('No profile picture URL, showing default icon'); // Debug
      return PhosphorIcon(
        PhosphorIcons.user(),
        size: 60,
        color: AppColors.primary,
      );
    }

    // Check if it's a base64 data URL
    if (_profilePictureUrl!.startsWith('data:image/')) {
      print('Loading base64 image'); // Debug
      try {
        final base64String = _profilePictureUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        print('Successfully decoded base64 image, ${bytes.length} bytes'); // Debug
        return ClipOval(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image.memory error: $error'); // Debug
                return PhosphorIcon(
                  PhosphorIcons.user(),
                  size: 60,
                  color: AppColors.primary,
                );
              },
            ),
          ),
        );
      } catch (e) {
        print('Error decoding base64 image: $e');
        return PhosphorIcon(
          PhosphorIcons.user(),
          size: 60,
          color: AppColors.primary,
        );
      }
    }

    // Regular HTTP URL
    print('Loading HTTP image'); // Debug
    return ClipOval(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Image.network(
          _profilePictureUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Image.network error: $error'); // Debug
            return PhosphorIcon(
              PhosphorIcons.user(),
              size: 60,
              color: AppColors.primary,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex.clamp(0, 1));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _updateProfilePicture() async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() => _isUploadingPhoto = true);
        
        final imageFile = File(pickedFile.path);
        await _authService.updateUserProfilePicture(imageFile);
        
        // Refresh profile picture URL from Firestore
        await _loadUserProfilePicture();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        icon: PhosphorIcon(
          PhosphorIcons.camera(),
          size: 24,
          color: AppColors.primary,
        ),
        title: const Text('Update Profile Picture'),
        content: const Text('Choose where to get your profile photo from:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            icon: PhosphorIcon(PhosphorIcons.camera()),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            icon: PhosphorIcon(PhosphorIcons.image()),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesCount = ref.watch(favoriteRecipeIdsProvider).length;
    final userRecipesCount = ref.watch(userRecipesCountProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: _buildProfileHeader(
                        favoritesCount,
                        userRecipesCount,
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          dividerColor: Colors.white,
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          tabs: [
                            Tab(
                              icon: PhosphorIcon(PhosphorIcons.heart()),
                              text: 'Favorites ($favoritesCount)',
                            ),
                            Tab(
                              icon: PhosphorIcon(PhosphorIcons.cookingPot()),
                              text: 'My Recipes ($userRecipesCount)',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: const [FavoritesGrid(), UserRecipesGrid()],
                  ),
                ),
                // Floating menu icon
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 16,
                  child: GestureDetector(
                    onTap: () {
                      print('Menu button tapped!'); // Debug
                      ProfileMenuBottomSheet.show(
                        context,
                        _showLogoutConfirmation,
                      );
                    },
                    child: PhosphorIcon(
                      PhosphorIcons.list(),
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(int favoritesCount, int userRecipesCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: _buildProfileImage(),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    onPressed: _isUploadingPhoto ? null : _updateProfilePicture,
                    icon: _isUploadingPhoto
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : PhosphorIcon(
                            PhosphorIcons.camera(),
                            color: Colors.white,
                            size: 16,
                          ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _user?.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
