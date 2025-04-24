import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? icon;
  final Color? backgroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style:
          backgroundColor != null
              ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
              : null,
      child:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
              : icon != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [icon!, const SizedBox(width: 8), Text(text)],
              )
              : Text(text),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
