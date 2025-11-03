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
import 'widgets/centered_form_view.dart';

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

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  // Ошибки для каждого поля
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _name = _nameController.text;
        _nameError = FormValidator.validateName(_name);
      });
    });

    _emailController.addListener(() {
      setState(() {
        _email = _emailController.text;
        _emailError = FormValidator.validateEmail(_email);
      });
    });

    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
        _passwordError = FormValidator.validatePassword(_password);
        // Перепроверяем подтверждение пароля при изменении основного пароля
        if (_confirmPassword.isNotEmpty) {
          _confirmPasswordError = FormValidator.validateConfirmPassword(
            _password,
            _confirmPassword,
          );
        }
      });
    });

    _confirmPasswordController.addListener(() {
      setState(() {
        _confirmPassword = _confirmPasswordController.text;
        _confirmPasswordError = FormValidator.validateConfirmPassword(
          _password,
          _confirmPassword,
        );
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
    final nameError = FormValidator.validateName(_name);
    final emailError = FormValidator.validateEmail(_email);
    final passwordError = FormValidator.validatePassword(_password);
    final confirmPasswordError = FormValidator.validateConfirmPassword(
      _password,
      _confirmPassword,
    );

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      // Обновляем состояние с ошибками
      setState(() {
        _nameError = nameError;
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    context.read<AccountDataBloc>().add(
      RegisterEvent(name: _name, email: _email, password: _password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: BlocListener<AccountDataBloc, AccountDataState>(
            listener: (context, state) {
              if (state is AccountDataError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AccountDataCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Успешная регистрация!')),
                );
                context.go('/gallery');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CenteredFormView(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    PressStart2PTitle(text: 'Регистрация'),
                    CustomFormField(
                      label: 'Имя',
                      hintText: 'Введите ваше имя',
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                      errorText: _nameError,
                    ),
                    CustomFormField(
                      label: 'e-mail',
                      hintText: 'Ваша электронная почта',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      errorText: _emailError,
                    ),
                    CustomFormField(
                      label: 'Пароль',
                      hintText: '8-16 символов',
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      obscureText: true,
                      errorText: _passwordError,
                    ),
                    CustomFormField(
                      label: 'Подтверждение пароля',
                      hintText: '8-16 символов',
                      keyboardType: TextInputType.text,
                      controller: _confirmPasswordController,
                      obscureText: true,
                      errorText: _confirmPasswordError,
                    ),
                  ],
                ),
                actions: [
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
