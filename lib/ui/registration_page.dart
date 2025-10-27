import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/account_data_bloc.dart';
import 'package:simple_paint/bloc/account_data_event.dart';
import 'package:simple_paint/bloc/account_data_state.dart';
import 'package:simple_paint/ui/widgets/custom_button.dart';
import 'package:simple_paint/ui/widgets/custom_form_field.dart';
import 'package:simple_paint/ui/widgets/press_start_2p_title.dart';

import '../utils/form_validator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Переменные состояния
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _name = _nameController.text;
      });
    });
    _emailController.addListener(() {
      setState(() {
        _email = _emailController.text;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
    _confirmPasswordController.addListener(() {
      setState(() {
        _confirmPassword = _confirmPasswordController.text;
      });
    });
  }

  bool get _isFormValid => FormValidator.isRegistrationFormValid(
    _name,
    _email,
    _password,
    _confirmPassword,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final error = FormValidator.validateRegistrationForm(
      _name,
      _email,
      _password,
      _confirmPassword,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.read<AccountDataBloc>().add(
      RegisterEvent(name: _name, email: _email, password: _password),
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        PressStart2PTitle(text: 'Регистрация'),
                        CustomFormField(
                          label: 'Имя',
                          hintText: 'Введите ваше имя',
                          controller: _nameController,
                        ),
                        CustomFormField(
                          label: 'e-mail',
                          hintText: 'Ваша электронная почта',
                          controller: _emailController,
                        ),
                        CustomFormField(
                          label: 'Пароль',
                          hintText: '8-16 символов',
                          controller: _passwordController,
                          obscureText: true,
                        ),
                        CustomFormField(
                          label: 'Подтверждение пароля',
                          hintText: '8-16 символов',
                          controller: _confirmPasswordController,
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<AccountDataBloc, AccountDataState>(
                    builder: (context, state) {
                      return CustomButton(
                        title:
                            state is AccountDataLoading
                                ? 'Загрузка...'
                                : 'Зарегистрироваться',
                        onPressed:
                            state is AccountDataLoading ? null : _register,
                        isEnable: _isFormValid,
                      );
                    },
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
