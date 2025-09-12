import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:io';
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
    Widget image;

    // Basic validation - just check if URL is not empty
    if (imageUrl.isEmpty) {
      return _buildDefaultErrorWidget();
    }

    // Check if the imageUrl is a local file path
    if (_isLocalFilePath(imageUrl)) {
      final file = File(imageUrl);
      if (file.existsSync()) {
        image = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildDefaultErrorWidget(),
        );
      } else {
        image = _buildDefaultErrorWidget();
      }
    } else {
      // Handle network URLs with cached network image
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: DefaultCacheManager(), // Use default for now
        maxWidthDiskCache: 1024,
        maxHeightDiskCache: 1024,
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: placeholder ?? (context, url) => _buildDefaultPlaceholder(),
        errorWidget: errorWidget ?? (context, url, error) => _buildDefaultErrorWidget(),
      );
    }

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

  bool _isLocalFilePath(String path) {
    // Check if it's a local file path (starts with / on Unix/Android, or C:\ on Windows)
    // Also check for common local file path patterns
    return path.startsWith('/') ||
           path.startsWith('file://') ||
           (path.length > 2 && path[1] == ':' && path[2] == '\\') || // Windows C:\
           path.startsWith('\\') || // Windows UNC path
           (!path.startsWith('http://') && !path.startsWith('https://') && !path.startsWith('data:'));
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    // Allow all HTTP/HTTPS URLs
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return true;
    }
    
    // Allow data URLs
    if (url.startsWith('data:image/')) {
      return url.contains('base64,');
    }
    
    // Allow local file paths
    return _isLocalFilePath(url);
  }

  bool _isValidImageFile(File file) {
    try {
      final stat = file.statSync();
      // Check if file has content (size > 0)
      return stat.size > 0;
    } catch (e) {
      return false;
    }
  }

  void _handleCorruptedFile(File file) {
    try {
      // Delete corrupted/empty file
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      // Ignore deletion errors
    }
  }

  void _handleImageError(String url, dynamic error) {
    // Log the error for debugging (you can integrate with your logging solution)
    debugPrint('Image loading error for URL: $url, Error: $error');
    
    // Clear cache for this URL if it's a network error
    if (error.toString().contains('Failed to decode image') || 
        error.toString().contains('empty')) {
      try {
        CachedNetworkImage.evictFromCache(url);
      } catch (e) {
        // Ignore cache eviction errors
      }
    }
  }

  CacheManager _createCustomCacheManager() {
    return CacheManager(
      Config(
        'customImageCache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 200,
        fileService: HttpFileService(),
      ),
    );
  }
}