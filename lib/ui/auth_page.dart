import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/bloc/account_data_event.dart';
import 'package:simple_paint/bloc/account_data_state.dart';
import 'package:simple_paint/ui/widgets/custom_button.dart';
import 'package:simple_paint/ui/widgets/custom_form_field.dart';
import 'package:simple_paint/ui/widgets/press_start_2p_title.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    context.read<AccountDataBloc>().add(
      LoginEvent(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: BlocListener<AccountDataBloc, AccountDataState>(
            listener: (context, state) {
              if (state is AccountDataError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AccountDataAuthenticated) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Успешный вход!')));
                context.go('/gallery');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PressStart2PTitle(text: 'Вход'),
                        //SizedBox(height: 20),
                        CustomFormField(
                          label: 'e-mail',
                          hintText: 'Введите электронную почту',
                          controller: _emailController,
                        ),
                        //SizedBox(height: 20),
                        CustomFormField(
                          label: 'Подтверждение пароля',
                          hintText: 'Введите пароль',
                          controller: _passwordController,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<AccountDataBloc, AccountDataState>(
                        builder: (context, state) {
                          return CustomButton(
                            title:
                                state is AccountDataLoading
                                    ? 'Загрузка...'
                                    : 'Войти',
                            onPressed:
                                state is AccountDataLoading ? null : _login,
                            isDark: true,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        title: 'Регистрация',
                        onPressed: () {
                          context.go('/registration');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
