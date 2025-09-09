import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onPressed;
  final String? customText;

  const LoadMoreButton({
    super.key,
    required this.isLoading,
    required this.hasMore,
    this.onPressed,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore && !isLoading) {
      return _buildEndOfResults();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? AppColors.background : AppColors.primary,
            foregroundColor: isLoading ? AppColors.textSecondary : AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isLoading 
                    ? AppColors.textSecondary.withOpacity(0.3)
                    : AppColors.primary,
                width: 1,
              ),
            ),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Loading more recipes...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.plus(),
                      size: 16,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      customText ?? 'Load More Recipes',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildEndOfResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: PhosphorIcon(
                PhosphorIcons.checkCircle(),
                size: 24,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'You\'ve seen all recipes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Check back later for new recipes featuring this ingredient',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}