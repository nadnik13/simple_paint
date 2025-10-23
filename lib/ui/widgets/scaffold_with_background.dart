import 'dart:ui';

import 'package:flutter/material.dart';

class ScaffoldWithBackground extends StatelessWidget {
  final Widget child;
  final AppBar appBar;

  const ScaffoldWithBackground({
    super.key,
    required this.child,
    required this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x4DE3E3E3), // 30% прозрачности для внешней тени
                  offset: Offset(0, 1),
                  blurRadius: 40,
                  spreadRadius: -64,
                ),
                BoxShadow(
                  color: Color(
                    0x33604490,
                  ), // 20% прозрачности для внутренней тени
                  offset: Offset(0, -82),
                  blurRadius: 68,
                  spreadRadius: -64,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21.0),
                  child: appBar,
                ),
              ),
            ),
          ),
        ),
        body: child,
      ),
    );
  }
}
