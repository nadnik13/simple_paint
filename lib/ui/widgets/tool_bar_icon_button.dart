import 'package:flutter/material.dart';

class ToolBarIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData iconData;

  const ToolBarIconButton({
    super.key,
    required this.onPressed,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white.withAlpha(20),
      child: Icon(iconData, size: 20.0, color: Colors.white),
    );
  }
}
