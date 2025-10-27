import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PressStart2PTitle extends StatelessWidget {
  final String text;

  const PressStart2PTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Обводка с градиентом
        ShaderMask(
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [Color(0xFF8924E7), Color(0xFF6A46F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: GoogleFonts.pressStart2p(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              foreground:
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = Colors.white,
            ),
          ),
        ),
        // Основной текст
        Text(
          text,
          textAlign: TextAlign.start,
          style: GoogleFonts.pressStart2p(
            shadows: [Shadow(color: Color(0xFF8924E7), blurRadius: 5)],
            color: Color(0xFFEEEEEE),
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
