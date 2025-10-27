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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              //enabled: false,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFC4C4C4).withValues(alpha: 0.01),
                  //border: Border.all(width: 0.5, color: Color(0xFF87858F)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Color(0x34E3E3E3).withValues(alpha: 0.2)),
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Color(0xFFC4C4C4).withValues(alpha: 0.01),
                      blurRadius: 40,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0xFF604490).withValues(alpha: 0.4),
                      //offset: Offset(0, -82),
                      blurRadius: 68,
                      spreadRadius: 64,
                    ),
                    BoxShadow(
                      offset: Offset(0, 10),
                      color: Color(0xFF131313).withValues(alpha: 0.8),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: appBar,
              ),
            ),
          ),
        ),
        body: child,
      ),
    );
  }
}

// class ScaffoldWithBackground extends StatelessWidget {
//   final Widget child;
//   final AppBar appBar;
//
//   const ScaffoldWithBackground({
//     super.key,
//     required this.child,
//     required this.appBar,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/background.png'),
//           fit: BoxFit.cover,
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: CustomScrollView(
//           //physics: const BouncingScrollPhysics(),
//           slivers: <Widget>[
//             SliverAppBar(
//               backgroundColor: Colors.transparent,
//               pinned: true,
//               //expandedHeight: 200.0,
//               flexibleSpace: FlexibleSpaceBar(
//                 title:
//                 //extendBodyBehindAppBar: true,
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
//                     //enabled: false,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Color(0xFFC4C4C4).withValues(alpha: 0.01),
//                         //border: Border.all(width: 0.5, color: Color(0xFF87858F)),
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Color(0x34E3E3E3).withValues(alpha: 0.2),
//                           ),
//                           BoxShadow(
//                             offset: Offset(0, 1),
//                             color: Color(0xFFC4C4C4).withValues(alpha: 0.01),
//                             blurRadius: 40,
//                             spreadRadius: 0,
//                           ),
//                           BoxShadow(
//                             color: Color(0xFF604490).withValues(alpha: 0.3),
//                             offset: Offset(0, -82),
//                             blurRadius: 68,
//                             spreadRadius: 64,
//                           ),
//                           BoxShadow(
//                             //offset: Offset(0, 1),
//                             color: Colors.black.withOpacity(0.7),
//                             blurRadius: 68,
//                             //spreadRadius: 64,
//                           ),
//                         ],
//                       ),
//                       child: appBar,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         //  Container(
//         //     decoration: BoxDecoration(
//         //       borderRadius: BorderRadius.only(
//         //         bottomRight: Radius.circular(8),
//         //         bottomLeft: Radius.circular(8),
//         //       ),
//         //       boxShadow: [
//         //         BoxShadow(
//         //           color: Color(0x4DE3E3E3), // 30% прозрачности для внешней тени
//         //           offset: Offset(0, 1),
//         //           blurRadius: 40,
//         //           spreadRadius: -64,
//         //         ),
//         //         BoxShadow(
//         //           color: Color(
//         //             0x33604490,
//         //           ), // 20% прозрачности для внутренней тени
//         //           offset: Offset(0, -82),
//         //           blurRadius: 68,
//         //           spreadRadius: -64,
//         //         ),
//         //       ],
//         //     ),
//         //     child: ClipRRect(
//         //       borderRadius: BorderRadius.only(
//         //         bottomRight: Radius.circular(8),
//         //         bottomLeft: Radius.circular(8),
//         //       ),
//         //       child: BackdropFilter(
//         //         filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
//         //         child: Padding(
//         //           padding: const EdgeInsets.symmetric(horizontal: 21.0),
//         //           child: appBar,
//         //         ),
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         // body: child,
//         //  ),
//       ),
//     );
//   }
// }
