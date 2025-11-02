import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<InternetConnectionState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectionSubscription;
  Timer? _periodicCheckTimer;
  Timer? _hideIndicatorTimer;

  InternetConnectionCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(InternetConnectionState.initial()) {
    _initializeConnection();
  }

  void _initializeConnection() {
    checkConnection(showIndicator: false);
    _startListening();
    _startPeriodicCheck();
  }

  void _startListening() {
    _connectionSubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateStateFromConnectivity(results);
      },
      onError: (error) {
        emit(state.disconnected('Ошибка подключения: $error'));
      },
    );
  }

  void _startPeriodicCheck() {
    print('_startPeriodicCheck');
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => checkConnection(showIndicator: false),
    );
  }

  void _updateStateFromConnectivity(List<ConnectivityResult> results) {
    print('_updateStateFromConnectivity');
    final hasAnyConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (hasAnyConnection) {
      print('hasAnyConnection');
      checkConnection();
    } else {
      print('Нет сетевого подключения');
      _cancelHideTimer();
      emit(state.disconnected('Нет сетевого подключения'));
    }
  }

  Future<void> checkConnection({bool showIndicator = true}) async {
    print('checkConnection state: ${state.isVisible}, showIndicator: $showIndicator');
    try {
      // Показываем индикатор подключения только если разрешено и мы не подключены
      if (showIndicator && !state.isConnected) {
        _cancelHideTimer();
        emit(state.connecting());
      }

      final connectivityResults = await _connectivity.checkConnectivity();
      final hasNetworkConnection = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );

      if (!hasNetworkConnection) {
        _cancelHideTimer();
        emit(state.disconnected('Нет сетевого подключения'));
        return;
      }

      final bool hasInternetAccess = await _checkInternetAccess();

      if (hasInternetAccess) {
        final wasDisconnected = state.isDisconnected || state.isConnecting;

        if (wasDisconnected && showIndicator) {
          // Показываем индикатор успешного подключения только если были проблемы и разрешено показывать
          emit(state.connected());
          _scheduleHideIndicator();
        } else if (!showIndicator) {
          // При инициализации остаемся в скрытом состоянии
          emit(state.connected(isVisible: false));
        }
      } else {
        _cancelHideTimer();
        emit(state.disconnected('Нет доступа к интернету'));
      }
    } catch (error) {
      _cancelHideTimer();
      emit(state.disconnected('Ошибка проверки подключения: $error'));
    }
  }

  Future<bool> _checkInternetAccess() async {
    print('_checkInternetAccess');
    try {
      final testUrls = ['https://www.google.com', 'https://1.1.1.1'];

      for (final url in testUrls) {
        try {
          final response = await http
              .head(Uri.parse(url), headers: {'User-Agent': 'SimplePaint/1.0'})
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            return true;
          }
        } catch (e) {
          continue;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> forceCheckConnection() async {
    print('forceCheckConnection');
    _cancelHideTimer();
    emit(state.connecting());
    await checkConnection(showIndicator: true);
  }

  void _scheduleHideIndicator() {
    print('_scheduleHideIndicator');
    _cancelHideTimer();
    _hideIndicatorTimer = Timer(const Duration(seconds: 5), () {
      if (state.isConnected) {
        emit(state.connected(isVisible: false));
      }
    });
  }

  /// Отменяет таймер скрытия индикатора
  void _cancelHideTimer() {
    _hideIndicatorTimer?.cancel();
    _hideIndicatorTimer = null;
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    _periodicCheckTimer?.cancel();
    _cancelHideTimer();
    return super.close();
  }
}
