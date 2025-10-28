import 'package:flutter/material.dart';

class ToolBarIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final bool isActive;

  const ToolBarIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor:
            isActive ? Colors.deepPurple : Colors.white.withAlpha(20),
        child: icon,
      ),
    );
  }
}
