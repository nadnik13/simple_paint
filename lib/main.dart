import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/bloc/gallery_bloc.dart';
import 'package:simple_paint/bloc/image_bloc.dart';
import 'package:simple_paint/data/fire_image_repo.dart';
import 'package:simple_paint/data/user_repo.dart';
import 'package:simple_paint/ui/auth_page.dart';
import 'package:simple_paint/ui/drawing_page.dart';
import 'package:simple_paint/ui/gallery_page.dart';
import 'package:simple_paint/ui/registration_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    if (state.fullPath == '/') {
      final user = FirebaseAuth.instance.currentUser;
      final loggingIn =
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/register';

      if (user == null && !loggingIn) return '/auth';
      if (user != null && loggingIn) return '/gallery';
      return null;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => AuthPage(),
      routes: [
        GoRoute(
          path: '/registration',
          builder: (context, state) => RegistrationPage(),
        ),
      ],
    ),

    /// Авторизованная зона — через ShellRoute
    ShellRoute(
      builder: (context, state, child) {
        final user = FirebaseAuth.instance.currentUser!;
        final userRepo = UserRepo(user.uid);
        final imageRepo = FireImageRepo(FirebaseFirestore.instance);

        // Здесь создаём "глобальные" провайдеры для всех авторизованных страниц
        return MultiBlocProvider(
          providers: [
            BlocProvider<GalleryBloc>(
              create:
                  (context) =>
                      GalleryBloc(userRepo: userRepo, imageRepo: imageRepo),
            ),
            BlocProvider<ImageBloc>(
              create:
                  (context) =>
                      ImageBloc(imageRepo: imageRepo, userRepo: userRepo),
            ),
          ],
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const GalleryPage(),
          routes: [
            GoRoute(
              path: '/draw',
              builder: (context, state) {
                final imageId = state.extra as String?;
                return DrawingPageWrapper(imageId: imageId);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountDataBloc>(
      create: (context) => AccountDataBloc(firebaseAuth: FirebaseAuth.instance),
      child: MaterialApp.router(
        title: 'Simple Paint',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: _router,
      ),
    );
  }
}
