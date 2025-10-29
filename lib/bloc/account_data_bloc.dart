import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/firebase_auth_error_helper.dart';
import 'account_data_event.dart';
import 'account_data_state.dart';

class AccountDataBloc extends Bloc<AccountDataEvent, AccountDataState> {
  final FirebaseAuth _firebaseAuth;

  AccountDataBloc({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth,
      super(AccountDataInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);

    add(CheckAuthStatusEvent());
  }

  void _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AccountDataState> emit,
  ) {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AccountDataAuthenticated(user: user));
    } else {
      emit(AccountDataUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AccountDataState> emit,
  ) async {
    emit(AccountDataLoading());

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        emit(AccountDataAuthenticated(user: credential.user!));
      } else {
        emit(const AccountDataError(message: 'Ошибка входа'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AccountDataError(message: FirebaseAuthErrorHelper.getErrorMessage(e)));
    } catch (e) {
      emit(AccountDataError(message: 'Неизвестная ошибка: $e'));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AccountDataState> emit,
  ) async {
    emit(AccountDataLoading());

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(event.name);
        await credential.user!.reload();

        final updatedUser = _firebaseAuth.currentUser;
        if (updatedUser != null) {
          emit(AccountDataAuthenticated(user: updatedUser));
        }
      } else {
        emit(const AccountDataError(message: 'Ошибка регистрации'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AccountDataError(message: FirebaseAuthErrorHelper.getErrorMessage(e)));
    } catch (e) {
      emit(AccountDataError(message: 'Неизвестная ошибка: $e'));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AccountDataState> emit,
  ) async {
    emit(AccountDataLoading());

    try {
      await _firebaseAuth.signOut();
      emit(AccountDataUnauthenticated());
    } catch (e) {
      emit(AccountDataError(message: 'Ошибка выхода: $e'));
    }
  }
}
