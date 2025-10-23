import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final bool isDark;
  final String title;
  final VoidCallback? onPressed;
  final bool isEnable;

  const CustomButton({
    super.key,
    this.isDark = false,
    this.isEnable = true,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          isDark
              ? BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isEnable
                          ? [const Color(0xFF8924E7), const Color(0xFF6A46F9)]
                          : [
                            const Color(0xFF8924E7).withValues(alpha: 0.5),
                            const Color(0xFF6A46F9).withValues(alpha: 0.5),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              )
              : BoxDecoration(
                color: isEnable ? Colors.white : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: isEnable ? onPressed : null,
        child: Text(
          title,
          style: TextStyle(
            color:
                isEnable
                    ? (isDark ? Colors.white : const Color(0xFF131313))
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFF131313).withValues(alpha: 0.5)),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
