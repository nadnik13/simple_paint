import 'package:equatable/equatable.dart';

abstract class AccountDataEvent extends Equatable {
  const AccountDataEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AccountDataEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AccountDataEvent {
  final String name;
  final String email;
  final String password;

  const RegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, email, password];
}

class LogoutEvent extends AccountDataEvent {}

class CheckAuthStatusEvent extends AccountDataEvent {}