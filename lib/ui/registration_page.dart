import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/bloc/account_data_event.dart';
import 'package:simple_paint/bloc/account_data_state.dart';
import 'package:simple_paint/ui/widgets/custom_button.dart';
import 'package:simple_paint/ui/widgets/custom_form_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль должен содержать минимум 8 символов'),
        ),
      );
      return;
    }

    if (password.length > 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пароль должен содержать не больше 16 символов'),
        ),
      );
      return;
    }

    context.read<AccountDataBloc>().add(
      RegisterEvent(name: name, email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.go('/auth');
        }
      },
      child: Scaffold(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Успешная регистрация!')),
                  );
                  context.go('/auth'); // Возвращаемся на страницу входа
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Регистрация', textAlign: TextAlign.start),
                        const SizedBox(height: 20),
                        CustomFormField(
                          label: 'Имя',
                          hintText: 'Введите ваше имя',
                          controller: _nameController,
                        ),
                        CustomFormField(
                          label: 'e-mail',
                          hintText: 'Введите электронную почту',
                          controller: _emailController,
                        ),
                        CustomFormField(
                          label: 'Пароль',
                          hintText: 'Введите пароль',
                          controller: _passwordController,
                          obscureText: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<AccountDataBloc, AccountDataState>(
                      builder: (context, state) {
                        return CustomButton(
                          title:
                              state is AccountDataLoading
                                  ? 'Загрузка...'
                                  : 'Зарегистрироваться',
                          onPressed:
                              state is AccountDataLoading ? null : _register,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
