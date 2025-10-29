import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AccountDataState extends Equatable {
  const AccountDataState();

  @override
  List<Object?> get props => [];
}

class AccountDataInitial extends AccountDataState {}

class AccountDataLoading extends AccountDataState {}

class AccountDataCreated extends AccountDataState {
  final User user;

  const AccountDataCreated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountDataAuthenticated extends AccountDataState {
  final User user;

  const AccountDataAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountDataUnauthenticated extends AccountDataState {}

class AccountDataError extends AccountDataState {
  final String message;

  const AccountDataError({required this.message});

  @override
  List<Object?> get props => [message];
}
