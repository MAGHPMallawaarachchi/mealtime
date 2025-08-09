import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double height;
  final double borderRadius;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.height = 52.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          foregroundColor: textColor ?? Colors.black87,
          disabledBackgroundColor: Colors.grey[100],
          disabledForegroundColor: Colors.grey[400],
          side: BorderSide(
            color: borderColor ?? Colors.grey.shade300,
            width: 1.0,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.black87,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}