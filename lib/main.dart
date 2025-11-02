import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/bloc/internet_connection_cubit.dart';
import 'package:simple_paint/data/gallery_repo.dart';
import 'package:simple_paint/ui/auth_page.dart';
import 'package:simple_paint/ui/drawing_page.dart';
import 'package:simple_paint/ui/gallery_page.dart';
import 'package:simple_paint/ui/registration_page.dart';
import 'package:simple_paint/utils/notification_helper.dart';

import 'bloc/canvas_bloc.dart';
import 'bloc/gallery_bloc.dart';
import 'bloc/image_bloc.dart';
import 'bloc/image_save_bloc.dart';
import 'bloc/toolbar_bloc.dart';
import 'data/fire_image_repo.dart';
import 'data/user_repo.dart';
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
    GoRoute(
      path: '/gallery',
      builder: (context, state) {
        final user = FirebaseAuth.instance.currentUser!;
        final userRepo = UserRepo(user.uid);
        final galleryRepo = GalleryRepo(FirebaseFirestore.instance);
        return BlocProvider<GalleryBloc>(
          create: (context) => GalleryBloc(userRepo: userRepo, galleryRepo: galleryRepo),
          child: const GalleryPage(),
        );
      },
      routes: [
        GoRoute(
          path: '/draw',
          builder: (context, state) {
            final imageId = state.extra as String?;
            final imageRepo = FireImageRepo(FirebaseFirestore.instance);
            final user = FirebaseAuth.instance.currentUser!;
            final userRepo = UserRepo(user.uid);
            return MultiBlocProvider(
              providers: [
                BlocProvider<ImageBloc>(
                  create: (context) => ImageBloc(imageRepo: imageRepo),
                ),
                BlocProvider<ImageSaveBloc>(
                  create:
                      (context) => ImageSaveBloc(
                        imageRepo: imageRepo,
                        userRepo: userRepo,
                      ),
                ),
                BlocProvider<ToolbarBloc>(create: (context) => ToolbarBloc()),
                BlocProvider<CanvasBloc>(create: (context) => CanvasBloc()),
              ],
              child: DrawingPage(imageId: imageId),
            );
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationHelper.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountDataBloc>(
          create: (context) => AccountDataBloc(firebaseAuth: FirebaseAuth.instance),
        ),
        BlocProvider<InternetConnectionCubit>(
          create: (context) => InternetConnectionCubit(),
        ),
      ],
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
