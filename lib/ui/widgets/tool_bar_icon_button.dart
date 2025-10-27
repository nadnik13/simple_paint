import 'package:flutter/material.dart';

class ToolBarIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;
  final bool isActive;

  const ToolBarIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        backgroundColor: isActive 
            ? Colors.blue.withAlpha(100) 
            : Colors.white.withAlpha(20),
        child: Icon(
          iconData, 
          size: 20.0, 
          color: isActive ? Colors.blue : Colors.white,
        ),
      ),
    );
  }
}
