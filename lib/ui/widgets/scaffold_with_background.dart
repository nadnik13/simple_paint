import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:simple_paint/ui/widgets/internet_connection_indicator.dart';

class ScaffoldWithBackground extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;

  const ScaffoldWithBackground({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar:
                appBar != null
                    ? PreferredSize(
                      preferredSize: Size.fromHeight(kToolbarHeight),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFC4C4C4).withValues(alpha: 0.01),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(
                                    0x34E3E3E3,
                                  ).withValues(alpha: 0.2),
                                ),
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Color(
                                    0xFFC4C4C4,
                                  ).withValues(alpha: 0.01),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color(
                                    0xFF604490,
                                  ).withValues(alpha: 0.4),
                                  //offset: Offset(0, -82),
                                  blurRadius: 68,
                                  spreadRadius: 64,
                                ),
                                BoxShadow(
                                  offset: Offset(0, 10),
                                  color: Color(
                                    0xFF131313,
                                  ).withValues(alpha: 0.8),
                                  blurRadius: 50,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: appBar,
                          ),
                        ),
                      ),
                    )
                    : null,
            body: child,
            bottomNavigationBar: InternetConnectionIndicator(),
          ),

          // Align(
          //   alignment: Alignment.topCenter,
          //   child: InternetConnectionIndicator(),
          // ),
        ],
      ),
    );
  }
}
