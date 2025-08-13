import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final bool preload;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.preload = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: DefaultCacheManager(),
      maxWidthDiskCache: 1024,
      maxHeightDiskCache: 1024,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      placeholder: placeholder ?? (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget ?? (context, url, error) => _buildDefaultErrorWidget(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      child: Center(
        child: PhosphorIcon(
          PhosphorIcons.image(),
          color: AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}