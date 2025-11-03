import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import 'internet_connection_state.dart';

class InternetConnectionCubit extends Cubit<ConnectionStatus> {
  final Connectivity _connectivity;
  StreamSubscription? _connectionSubscription;

  InternetConnectionCubit({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(ConnectionStatus.connected) {
    _initializeConnection();
  }

  void _initializeConnection() {
    _connectionSubscription =
        CombineLatestStream.combine2<bool, List<ConnectivityResult>, bool>(
          Stream.periodic(
            Duration(seconds: 60),
          ).asyncMap((_) async => await _checkInternetAccess()).startWith(true),
          _connectivity.onConnectivityChanged,
          (hasInternetAccess, connectivityState) {
            if (connectivityState.length == 1 &&
                connectivityState.single == ConnectivityResult.none) {
              return false;
            }
            return hasInternetAccess;
          },
        ).listen((hasConnection) {
          if (hasConnection) {
            emit(ConnectionStatus.connected);
          } else {
            emit(ConnectionStatus.disconnected);
          }
        });
  }

  Future<bool> _checkInternetAccess() async {
    try {
      if (state == ConnectionStatus.disconnected) {
        emit(ConnectionStatus.connecting);
      }
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

  @override
  Future<void> close() async {
    _connectionSubscription?.cancel();
    super.close();
  }
}
