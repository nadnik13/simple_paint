import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/ui/auth_page.dart';
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
      return '/auth';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/auth', builder: (context, state) => AuthPage()),
    GoRoute(
      path: '/registration',
      builder: (context, state) => RegistrationPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountDataBloc(firebaseAuth: FirebaseAuth.instance),
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: _router,
      ),
    );
  }
}
